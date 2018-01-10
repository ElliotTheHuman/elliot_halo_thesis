# Using this PDT to grab a lot of additional stats!

view: matches_facts {
  derived_table: {
    sql:
      SELECT
        JSON_EXTRACT_SCALAR(Results,"$.Players[0].Player.Gamertag") AS gamertag,
        AVG(CASE WHEN CAST(JSON_EXTRACT_SCALAR(Results,"$.Players[0].TotalDeaths") AS INT64) = 0
                THEN CAST(JSON_EXTRACT_SCALAR(Results,"$.Players[0].TotalKills") AS INT64)*1.0/1
             ELSE CAST(JSON_EXTRACT_SCALAR(Results,"$.Players[0].TotalKills") AS INT64)*1.0/CAST(JSON_EXTRACT_SCALAR(Results,"$.Players[0].TotalDeaths") AS INT64)
             END) AS average_kill_death_ratio_over_matches
      FROM
        matches
      GROUP BY
        gamertag ;;

    sql_trigger_value: 1 ;;
  }

  dimension: gamertag {
    type: string
    sql: ${TABLE}.gamertag ;;
  }

  dimension: average_kill_death_ratio_over_matches  {
    type: number
    sql: ${TABLE}.average_kill_death_ratio_over_matches ;;
    value_format: "0.00"
  }

  measure: max_average_kilL_death_raito_over_matches {
    type: max
    sql: ${average_kill_death_ratio_over_matches} ;;
    value_format: "0.00"
  }
}
