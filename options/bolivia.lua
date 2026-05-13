-- =============================================================================
-- PERFIL DE CONDUCCIÓN PARA BOLIVIA - OSRM
-- =============================================================================
-- Este archivo define cómo OSRM calcula rutas para vehículos en Bolivia.
-- Está basado en el perfil oficial de OSRM para autos, pero ajustado a la
-- realidad boliviana: altitud, pendientes, calles urbanas estrechas,
-- caminos de tierra, y tráfico denso en ciudades como La Paz y El Alto.
--
-- ⚠️  IMPORTANTE: Si modificas este archivo, debes volver a procesar los datos.
--     Ver sección "Cómo aplicar cambios" al final de este archivo.
-- =============================================================================

api_version = 4

Set = require('lib/set')
Sequence = require('lib/sequence')
Handlers = require("lib/way_handlers")
Relations = require("lib/relations")
find_access_tag = require("lib/access").find_access_tag
limit = require("lib/maxspeed").limit
Utils = require("lib/utils")
Measure = require("lib/measure")

function setup()
  return {
    properties = {
      -- Velocidad máxima usada para el map-matching (GPS → ruta).
      -- En Bolivia no hay autopistas de alta velocidad, 120 km/h es suficiente.
      max_speed_for_map_matching = 120/3.6,

      -- 'routability': balancea duración + preferencia de vías principales.
      -- Es el modo más realista para Bolivia porque penaliza calles secundarias
      -- y caminos de tierra, favoreciendo rutas más rápidas aunque no sean las más cortas.
      -- Alternativas: 'duration' (solo tiempo), 'distance' (solo distancia)
      weight_name = 'routability',

      process_call_tagless_node = false,

      -- Penalización por dar vuelta en U (segundos).
      -- En La Paz y ciudades bolivianas los giros en U son comunes pero lentos.
      -- Valor alto = OSRM los evita más. Rango útil: 40-120.
      u_turn_penalty = 80,

      -- Si es true, OSRM intenta continuar recto en los waypoints intermedios.
      -- Útil para rutas de reparto o logística con múltiples paradas.
      continue_straight_at_waypoint = true,

      -- Respetar restricciones de giro del mapa (sentidos, prohibiciones).
      -- Siempre true para resultados realistas.
      use_turn_restrictions = true,

      -- Bolivia maneja por la derecha.
      left_hand_driving = false,

      -- Penalización por semáforo (segundos de espera estimada).
      -- En La Paz los semáforos son lentos y hay muchos. Rango útil: 20-45.
      traffic_light_penalty = 35,
    },

    default_mode = mode.driving,

    -- Velocidad por defecto para vías sin tipo definido (km/h).
    -- 10 km/h es conservador, apropiado para calles sin clasificar en Bolivia.
    default_speed = 10,

    oneway_handling = true,

    -- Multiplicador de velocidad para calles laterales/secundarias.
    -- 0.5 = las calles de acceso se consideran al 50% de velocidad.
    -- Reduce la preferencia por atajos por callejones. Rango: 0.3-0.8.
    side_road_multiplier = 0.5,

    -- Penalización base por giro en intersecciones (segundos).
    -- Bolivia tiene muchas intersecciones sin semáforo. Rango útil: 15-40.
    turn_penalty = 30,

    -- Factor de reducción de velocidad en zonas con restricciones.
    -- 0.4 = reduce al 40% en zonas de acceso restringido. Rango: 0.3-0.6.
    speed_reduction = 0.4,

    -- Sesgo de giro: >1 prefiere giros a la derecha (conducción por la derecha).
    -- Bolivia conduce por la derecha, valor 1.2 es correcto.
    turn_bias = 1.2,

    cardinal_directions = false,

    -- ==========================================================================
    -- DIMENSIONES DEL VEHÍCULO
    -- Limitan el acceso a vías con restricciones físicas (puentes, túneles, etc.)
    -- Ajustar si el perfil es para camiones o vehículos especiales.
    -- ==========================================================================
    vehicle_height = 2.0,   -- metros (SUV grande ~1.9m)
    vehicle_width  = 1.9,   -- metros (vías "narrow" se consideran < 2.2m)
    vehicle_length = 4.8,   -- metros (auto familiar grande)
    vehicle_weight = 2000,  -- kilogramos

    suffix_list = {
      'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW',
      'North', 'South', 'West', 'East', 'Nor', 'Sou', 'We', 'Ea'
    },

    -- ==========================================================================
    -- BARRERAS PERMITIDAS
    -- Tipos de barrera que NO bloquean el paso del vehículo.
    -- ==========================================================================
    barrier_whitelist = Set {
      'cattle_grid',
      'border_control',
      'toll_booth',
      'sally_port',
      'gate',
      'lift_gate',
      'no',
      'entrance',
      'height_restrictor',
      'arch'
    },

    -- ==========================================================================
    -- CONTROL DE ACCESO
    -- Define qué etiquetas OSM permiten o bloquean el paso.
    -- ==========================================================================
    access_tag_whitelist = Set {
      'yes',
      'motorcar',
      'motor_vehicle',
      'vehicle',
      'permissive',
      'designated',
      'hov'
    },

    access_tag_blacklist = Set {
      'no',
      'agricultural',
      'forestry',
      'emergency',
      'psv',
      'customers',
      'private',
      'delivery',
      'destination'
    },

    service_access_tag_blacklist = Set {
      'private'
    },

    restricted_access_tag_list = Set {
      'private',
      'delivery',
      'destination',
      'customers',
    },

    access_tags_hierarchy = Sequence {
      'motorcar',
      'motor_vehicle',
      'vehicle',
      'access'
    },

    service_tag_forbidden = Set {
      'emergency_access'
    },

    restrictions = Sequence {
      'motorcar',
      'motor_vehicle',
      'vehicle'
    },

    classes = Sequence {
      'toll', 'motorway', 'ferry', 'restricted', 'tunnel'
    },

    excludable = Sequence {
      Set {'toll'},
      Set {'motorway'},
      Set {'ferry'}
    },

    avoid = Set {
      'area',
      -- 'toll',       -- descomenta para evitar peajes
      'reversible',
      'impassable',
      'hov_lanes',
      'steps',
      'construction',
      'proposed'
    },

    -- ==========================================================================
    -- VELOCIDADES POR TIPO DE VÍA (km/h)
    -- ==========================================================================
    -- Estas velocidades reflejan la realidad boliviana:
    -- - No existen autopistas de alta velocidad (motorway real en Bolivia es escaso)
    -- - Las vías primarias tienen semáforos, cruces y tráfico pesado
    -- - Las calles residenciales son estrechas y con pendientes fuertes
    -- - Los caminos secundarios y terciarios suelen ser de tierra o ripio
    --
    -- Para ajustar: sube el valor si quieres rutas más rápidas por ese tipo de vía,
    -- bájalo si quieres que OSRM las evite más.
    -- ==========================================================================
    speeds = Sequence {
      highway = {
        -- Autopistas/dobles vías (ej: carretera La Paz-Oruro, anillo periférico)
        -- Bolivia no tiene autopistas reales; estas son las mejores carreteras del país.
        motorway        = 80,
        motorway_link   = 40,

        -- Troncales nacionales (ej: carretera a Cochabamba, a Santa Cruz)
        -- Velocidad reducida por curvas, pendientes y tráfico mixto.
        trunk           = 60,
        trunk_link      = 30,

        -- Vías primarias urbanas (ej: Av. Montes, Av. Arce en La Paz)
        -- Semáforos frecuentes, tráfico denso, minibuses.
        primary         = 35,
        primary_link    = 20,

        -- Vías secundarias (calles principales de barrio)
        secondary       = 25,
        secondary_link  = 18,

        -- Vías terciarias (calles de barrio, accesos)
        tertiary        = 18,
        tertiary_link   = 12,

        -- Vías sin clasificar (calles sin datos suficientes en OSM)
        -- Conservador porque pueden ser de tierra o muy estrechas.
        unclassified    = 15,

        -- Calles residenciales: estrechas, con pendientes, peatones frecuentes.
        residential     = 12,

        -- Calles de convivencia (zonas 30, pasajes peatonales con acceso vehicular)
        living_street   = 7,

        -- Vías de servicio (estacionamientos, accesos internos)
        service         = 10,
      }
    },

    -- ==========================================================================
    -- PENALIZACIONES POR TIPO DE SERVICIO
    -- Reduce la velocidad efectiva en vías de servicio específicas.
    -- 0.5 = se usa al 50% de la velocidad base.
    -- ==========================================================================
    service_penalties = {
      alley             = 0.5,   -- callejones
      parking           = 0.5,   -- estacionamientos
      parking_aisle     = 0.5,   -- pasillos de estacionamiento
      driveway          = 0.5,   -- entradas privadas
      ["drive-through"] = 0.5,
      ["drive-thru"]    = 0.5
    },

    -- Tipos de vía que pueden tener acceso restringido pero aún son ruteables.
    restricted_highway_whitelist = Set {
      'motorway', 'motorway_link',
      'trunk', 'trunk_link',
      'primary', 'primary_link',
      'secondary', 'secondary_link',
      'tertiary', 'tertiary_link',
      'residential',
      'living_street',
      'unclassified',
      'service'
    },

    construction_whitelist = Set {
      'no',
      'widening',
      'minor',
    },

    -- Velocidades para rutas especiales (ferry, tren)
    route_speeds = {
      ferry         = 5,
      shuttle_train = 10
    },

    bridge_speeds = {
      movable = 5   -- puentes móviles (levadizos, etc.)
    },

    -- ==========================================================================
    -- VELOCIDADES MÁXIMAS POR SUPERFICIE
    -- ==========================================================================
    -- Bolivia tiene una gran variedad de superficies: asfalto en ciudades,
    -- ripio y tierra en el campo, adoquines en zonas históricas.
    -- Estos valores limitan la velocidad según la superficie etiquetada en OSM.
    -- nil = sin límite adicional (se usa la velocidad del tipo de vía).
    -- ==========================================================================
    surface_speeds = {
      -- Superficies pavimentadas: sin límite adicional
      asphalt             = nil,
      concrete            = nil,
      ["concrete:plates"] = nil,
      ["concrete:lanes"]  = nil,
      paved               = nil,

      -- Superficies semi-pavimentadas
      cement              = 60,
      compacted           = 50,   -- tierra compactada, común en Bolivia
      fine_gravel         = 40,

      paving_stones       = 40,   -- adoquines (frecuentes en centros históricos)
      metal               = 40,
      bricks              = 30,

      -- Superficies naturales
      grass               = 20,
      wood                = 20,
      sett                = 30,   -- adoquines irregulares
      grass_paver         = 20,
      gravel              = 20,   -- ripio, muy común en caminos bolivianos
      unpaved             = 25,   -- sin pavimentar (tierra/ripio genérico)
      ground              = 20,
      dirt                = 15,   -- tierra suelta, caminos rurales
      pebblestone         = 25,
      tartan              = 30,

      cobblestone         = 25,   -- adoquín colonial (La Paz, Sucre, Potosí)
      clay                = 15,   -- arcilla, resbaladiza cuando llueve

      earth               = 15,
      stone               = 20,
      rocky               = 15,   -- caminos rocosos (frecuentes en altiplano)
      sand                = 10,

      mud                 = 5,    -- barro: muy lento y peligroso
    },

    -- ==========================================================================
    -- VELOCIDADES POR TIPO DE CAMINO (tracktype)
    -- ==========================================================================
    -- grade1 = camino bien mantenido (casi asfalto)
    -- grade5 = camino apenas transitable (huella en campo)
    -- Muy relevante para Bolivia donde muchos caminos rurales son tracks.
    -- ==========================================================================
    tracktype_speeds = {
      grade1 = 50,   -- camino consolidado, bien mantenido
      grade2 = 35,   -- camino de ripio en buen estado
      grade3 = 25,   -- camino de tierra regular
      grade4 = 15,   -- camino de tierra malo, con baches
      grade5 = 10,   -- huella, apenas transitable
    },

    -- ==========================================================================
    -- VELOCIDADES POR ESTADO DE LA VÍA (smoothness)
    -- ==========================================================================
    -- Complementa tracktype. Si OSM tiene etiqueta smoothness, se aplica este límite.
    -- ==========================================================================
    smoothness_speeds = {
      intermediate  = 60,   -- algunos baches menores
      bad           = 30,   -- baches frecuentes
      very_bad      = 15,   -- muy deteriorado
      horrible      = 8,    -- casi intransitable
      very_horrible = 4,
      impassable    = 0,    -- no se puede pasar
    },

    -- ==========================================================================
    -- VELOCIDADES MÁXIMAS LEGALES POR DEFECTO (Bolivia)
    -- ==========================================================================
    -- Fuente: Reglamento de Tránsito de Bolivia
    -- Estas se aplican cuando no hay etiqueta maxspeed en el mapa.
    -- ==========================================================================
    maxspeed_table_default = {
      urban    = 40,    -- límite urbano Bolivia: 40 km/h (antes era 50)
      rural    = 80,    -- carreteras rurales
      trunk    = 100,   -- troncales nacionales
      motorway = 120,   -- dobles vías / anillos
    },

    -- Excepciones por país (se mantienen para compatibilidad con datos OSM internacionales)
    maxspeed_table = {
      ["at:rural"] = 100,
      ["at:trunk"] = 100,
      ["be:motorway"] = 120,
      ["be-bru:rural"] = 70,
      ["be-bru:urban"] = 30,
      ["be-vlg:rural"] = 70,
      ["by:urban"] = 60,
      ["by:motorway"] = 110,
      ["ch:rural"] = 80,
      ["ch:trunk"] = 100,
      ["ch:motorway"] = 120,
      ["cz:trunk"] = 0,
      ["cz:motorway"] = 0,
      ["de:living_street"] = 7,
      ["de:rural"] = 100,
      ["de:motorway"] = 0,
      ["dk:rural"] = 80,
      ["fr:rural"] = 80,
      ["gb:nsl_single"] = (60*1609)/1000,
      ["gb:nsl_dual"] = (70*1609)/1000,
      ["gb:motorway"] = (70*1609)/1000,
      ["nl:rural"] = 80,
      ["nl:trunk"] = 100,
      ['no:rural'] = 80,
      ['no:motorway'] = 110,
      ['pl:rural'] = 100,
      ['pl:trunk'] = 120,
      ['pl:motorway'] = 140,
      ["ro:trunk"] = 100,
      ["ru:living_street"] = 20,
      ["ru:urban"] = 60,
      ["ru:motorway"] = 110,
      ["uk:nsl_single"] = (60*1609)/1000,
      ["uk:nsl_dual"] = (70*1609)/1000,
      ["uk:motorway"] = (70*1609)/1000,
      ['za:urban'] = 60,
      ['za:rural'] = 100,
      ["none"] = 120,   -- sin límite explícito: máximo 120 en Bolivia
    },

    relation_types = Sequence {
      "route"
    },

    highway_turn_classification = {},
    access_turn_classification  = {}
  }
end

-- =============================================================================
-- PROCESAMIENTO DE NODOS (semáforos, barreras)
-- No necesita modificación para ajustes de velocidad/ruta.
-- =============================================================================
function process_node(profile, node, result, relations)
  local access = find_access_tag(node, profile.access_tags_hierarchy)
  if access then
    if profile.access_tag_blacklist[access] and not profile.restricted_access_tag_list[access] then
      result.barrier = true
    end
  else
    local barrier = node:get_value_by_key("barrier")
    if barrier then
      local restricted_by_height = false
      if barrier == 'height_restrictor' then
        local maxheight = Measure.get_max_height(node:get_value_by_key("maxheight"), node)
        restricted_by_height = maxheight and maxheight < profile.vehicle_height
      end

      local bollard = node:get_value_by_key("bollard")
      local rising_bollard = bollard and "rising" == bollard

      local kerb = node:get_value_by_key("kerb")
      local highway = node:get_value_by_key("highway")
      local flat_kerb = kerb and ("lowered" == kerb or "flush" == kerb)
      local highway_crossing_kerb = barrier == "kerb" and highway and highway == "crossing"

      if not profile.barrier_whitelist[barrier]
          and not rising_bollard
          and not flat_kerb
          and not highway_crossing_kerb
          or restricted_by_height then
        result.barrier = true
      end
    end
  end

  local tag = node:get_value_by_key("highway")
  if "traffic_signals" == tag then
    result.traffic_lights = true
  end
end

-- =============================================================================
-- PROCESAMIENTO DE VÍAS
-- Aplica todos los handlers en orden: acceso → velocidad → superficie → penalizaciones.
-- =============================================================================
function process_way(profile, way, result, relations)
  local data = {
    highway = way:get_value_by_key('highway'),
    bridge  = way:get_value_by_key('bridge'),
    route   = way:get_value_by_key('route')
  }

  if (not data.highway or data.highway == '') and
     (not data.route   or data.route   == '')
  then
    return
  end

  handlers = Sequence {
    WayHandlers.default_mode,
    WayHandlers.blocked_ways,
    WayHandlers.avoid_ways,
    WayHandlers.handle_height,
    WayHandlers.handle_width,
    WayHandlers.handle_length,
    WayHandlers.handle_weight,
    WayHandlers.access,
    WayHandlers.oneway,
    WayHandlers.destinations,
    WayHandlers.ferries,
    WayHandlers.movables,
    WayHandlers.service,
    WayHandlers.hov,
    -- Orden importante: speed base → maxspeed del mapa → superficie → penalizaciones
    WayHandlers.speed,
    WayHandlers.maxspeed,
    WayHandlers.surface,
    WayHandlers.penalties,
    WayHandlers.classes,
    WayHandlers.turn_lanes,
    WayHandlers.classification,
    WayHandlers.roundabouts,
    WayHandlers.startpoint,
    WayHandlers.driving_side,
    WayHandlers.names,
    WayHandlers.weights,
    WayHandlers.way_classification_for_turn
  }

  WayHandlers.run(profile, way, result, data, handlers, relations)

  if profile.cardinal_directions then
    Relations.process_way_refs(way, relations, result)
  end
end

-- =============================================================================
-- PROCESAMIENTO DE GIROS
-- =============================================================================
-- Calcula la penalización de tiempo al girar en una intersección.
-- La fórmula sigmoide hace que giros de 90° tengan penalización media,
-- y giros de 180° (U-turn) tengan la penalización máxima.
--
-- Para ajustar el comportamiento en intersecciones:
--   - Sube turn_penalty (en setup) para que OSRM evite más los giros
--   - Sube traffic_light_penalty para simular semáforos más lentos
--   - Sube u_turn_penalty para evitar más los giros en U
-- =============================================================================
function process_turn(profile, turn)
  local turn_penalty = profile.turn_penalty
  local turn_bias = turn.is_left_hand_driving and 1. / profile.turn_bias or profile.turn_bias

  if turn.has_traffic_light then
    turn.duration = profile.properties.traffic_light_penalty
  end

  if turn.number_of_roads > 2 or turn.source_mode ~= turn.target_mode or turn.is_u_turn then
    if turn.angle >= 0 then
      turn.duration = turn.duration + turn_penalty / (1 + math.exp( -((13 / turn_bias) *  turn.angle/180 - 6.5*turn_bias)))
    else
      turn.duration = turn.duration + turn_penalty / (1 + math.exp( -((13 * turn_bias) * -turn.angle/180 - 6.5/turn_bias)))
    end

    if turn.is_u_turn then
      turn.duration = turn.duration + profile.properties.u_turn_penalty
    end
  end

  if profile.properties.weight_name == 'distance' then
    turn.weight = 0
  else
    turn.weight = turn.duration
  end

  if profile.properties.weight_name == 'routability' then
    if not turn.source_restricted and turn.target_restricted then
      turn.weight = constants.max_turn_weight
    end
  end
end

return {
  setup        = setup,
  process_way  = process_way,
  process_node = process_node,
  process_turn = process_turn
}

-- =============================================================================
-- CÓMO APLICAR CAMBIOS A ESTE ARCHIVO
-- =============================================================================
-- Modificar este .lua NO tiene efecto hasta que se reprocesen los datos OSM.
-- Pasos para aplicar cambios:
--
--   1. Detener el servicio:
--        npm stop
--
--   2. Eliminar los archivos procesados anteriores:
--        npm run clean
--
--   3. Volver a instalar (reprocesa con el nuevo perfil):
--        npm run install-osrm
--
--   4. Esperar ~15-20 minutos (primera vez) o ~10 min (si los datos .pbf ya existen)
--
-- ⚠️  El archivo .pbf (datos de Bolivia) NO se borra con npm run clean.
--     Solo se borran los archivos .osrm procesados, lo que ahorra tiempo de descarga.
-- =============================================================================
