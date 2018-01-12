view: metadata_csr_designations {

  sql_table_name: halo_5_dataset.metadata_csr_designations ;;

  dimension: Results {
    type: string
    sql: ${TABLE}.Results ;;
  }

  dimension: class_id {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${Results},"$.id") AS INT64) ;;
  }

  dimension: class_name {
    type: string
    sql: CASE WHEN JSON_EXTRACT_SCALAR(${Results},"$.name") IS NULL THEN "Unranked"
              ELSE JSON_EXTRACT_SCALAR(${Results},"$.name")
              END ;;
  }
}
