include: "*.view.lkml"

view: matches_sessions {
  derived_table: {

    partition_keys: ["matches_match_completed_date_date"]

    sql: SELECT
        EXTRACT(DATE FROM CAST(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchCompletedDate.ISO8601Date") AS TIMESTAMP)) AS matches_match_completed_date_date
      FROM halo_5_dataset.matches  AS matches
      GROUP BY 1
      ORDER BY 1 DESC
       ;;

      sql_trigger_value: SELECT 1 ;;
  }

  dimension: compound_primary_key {
    hidden: yes
    type: string
    sql: CONCAT(${TABLE}.gamertag,' ',${TABLE}.matches_match_completed_date_date) ;;
    primary_key: yes
  }

  dimension_group: completed_date {
    type: time
    datatype: date
    timeframes: [date]
    sql: ${TABLE}.matches_match_completed_date_date ;;
  }

  dimension: gamertag {
    type: string
    sql: ${TABLE}.matches_gamertag ;;
  }

  dimension: session_duration {
    type: number
    sql: ${TABLE}.matches_sum_match_duration_in_minutes ;;
  }

  measure: average_session_duration {
    type: average
    sql: ${session_duration} ;;
  }

  measure: max_session_duration {
    type: max
    sql: ${session_duration} ;;
  }
}
