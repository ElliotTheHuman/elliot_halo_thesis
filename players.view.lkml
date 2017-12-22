view: players {
  sql_table_name: halo_5_dataset.players ;;

  ############ JSON BLOBS ############

  dimension: gamertag_column {
    type: string
    sql: ${TABLE}.Gamertags ;;
    hidden: yes
  }

  dimension: results_column {
    type: string
    sql: ${TABLE}.Results ;;
    hidden: yes
  }

  ############ DIMENSIONS ############

  dimension: gamertag {
    type: string
    sql: JSON_EXTRACT_SCALAR(${gamertag_column},"$.Gamertag") ;;
    primary_key: yes
  }

  dimension: rank_class {
    type: number
    sql: JSON_EXTRACT_SCALAR(${results_column},"$.Csr.DesignationId");;
  }

  dimension: rank_tier {
    type: number
    sql: JSON_EXTRACT_SCALAR(${results_column},"$.Csr.Tier" ;;
  }

  dimension: total_kills {
    type: number
    sql:  ;;
}

############ MEASURES ############

measure: count {
  type: count
}

}
