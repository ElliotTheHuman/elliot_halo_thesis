view: metadata_maps {
  sql_table_name: halo_5_dataset.metadata_maps ;;

############ JSON BLOBS ############

  dimension: results {
    type: string
    sql: ${TABLE}.Results ;;
    hidden: yes
  }

  ############ DIMENSIONS ############

  dimension: name {
    type: string
    sql: TRIM(JSON_EXTRACT_SCALAR(${results},"$.name")," ") ;;
    link: {
      label: "Map Dashboard"
      url: "https://dcl.dev.looker.com/dashboards/81?Map%20Name=Regret&filter_config=%7B%22Map%20Name%22:%5B%7B%22type%22:%22%3D%22,%22values%22:%5B%7B%22constant%22:%22{{ value }}%22%7D,%7B%7D%5D,%22id%22:0%7D%5D%7D"
      icon_url: "https://vignette.wikia.nocookie.net/callofduty/images/4/4e/Captain_Price.jpg/revision/latest?cb=20070618194007"
    }
  }

  dimension: id {
    type: string
    sql: JSON_EXTRACT_SCALAR(${results},"$.id") ;;
    primary_key: yes
  }

  parameter: testparam {
    type: string
  }

  dimension: drill_map_name {
    type: string
    sql: CASE
          WHEN {% parameter testparam %} = 'Alpine' THEN 'Alpine'
          WHEN {% parameter testparam %} = 'Breakout Arena' THEN 'Breakout Arena'
          WHEN {% parameter testparam %} = 'Coliseum' THEN 'Coliseum'
          WHEN {% parameter testparam %} = 'Eden' THEN 'Eden'
          WHEN {% parameter testparam %} = 'Empire' THEN 'Empire'
          WHEN {% parameter testparam %} = 'Fathom' THEN 'Fathom'
          WHEN {% parameter testparam %} = 'Glacier' THEN 'Glacier'
          WHEN {% parameter testparam %} = 'Mercy' THEN 'Mercy'
          WHEN {% parameter testparam %} = 'Overgrowth' THEN 'Overgrowth'
          WHEN {% parameter testparam %} = 'Parallax' THEN 'Parallax'
          WHEN {% parameter testparam %} = 'Plaza' THEN 'Plaza'
          WHEN {% parameter testparam %} = 'Regret' THEN 'Regret'
          WHEN {% parameter testparam %} = 'Riptide' THEN 'Riptide'
          WHEN {% parameter testparam %} = 'Slag' THEN 'Slag'
          WHEN {% parameter testparam %} = 'Stasis' THEN 'Stasis'
          WHEN {% parameter testparam %} = 'The Rig' THEN 'The Rig'
          WHEN {% parameter testparam %} = 'Torque' THEN 'Torque'
          WHEN {% parameter testparam %} = 'Truth' THEN 'Truth'
          WHEN {% parameter testparam %} = 'Tyrant' THEN 'Tyrant'
         END ;;
  }
}
