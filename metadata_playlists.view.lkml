view: metadata_playlists {
  sql_table_name: halo_5_dataset.metadata_playlists ;;

############ JSON BLOBS ############

  dimension: results {
    type: string
    sql: ${TABLE}.Results ;;
    hidden: yes
  }

  ############ DIMENSIONS ############

  dimension: name {
    type: string
    sql: RTRIM(JSON_EXTRACT_SCALAR(${results},"$.name")," ") ;;
  }

  dimension: description {
    type: string
    sql: JSON_EXTRACT_SCALAR(${results},"$.description") ;;
  }

  dimension: id {
    type: string
    sql: JSON_EXTRACT_SCALAR(${results},"$.id") ;;
    primary_key: yes
  }

  dimension: is_ranked {
    type: yesno
    sql: ${name} IN ("Slayer", "Free-for-All","Team Arena","HaloWC Preview","Breakout","Snipers","Doubles","SWAT") ;;
  }

  set: some_set {
    fields: [name]
  }

  ############ Test ############

  filter: test {
    type: string
  }

  dimension: some_dim {
    type: string
    sql: 1 ;;
    html: {{ _filters['metadata_playlists.test'] }} ;;
  }
}
