view: metadata_playlists {
  sql_table_name: halo_5_dataset.metadata_playlists ;;

############ JSON BLOBS ############

  dimension: results {
    type: string
    sql: ${TABLE}.Results ;;
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
}
