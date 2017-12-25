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
  }

  dimension: id {
    type: string
    sql: JSON_EXTRACT_SCALAR(${results},"$.id") ;;
    primary_key: yes
  }
}
