view: testing_stuff {
  derived_table: {
    sql:
      SELECT * FROM ${matches.SQL_TABLE_NAME};;
  }

  dimension: results {
    type: string
    sql: ${TABLE}.Results ;;
  }
}
