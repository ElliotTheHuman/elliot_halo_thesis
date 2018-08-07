include: "*.view.lkml"

view: matches_sessions {
  derived_table: {
    sql: SELECT
        CAST(CAST(EXTRACT(DATE FROM CAST(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchCompletedDate.ISO8601Date") AS TIMESTAMP)) AS TIMESTAMP) AS DATE) AS matches_match_completed_date_date,
        JSON_EXTRACT_SCALAR(matches.Results,"$.Players[0].Player.Gamertag")  AS matches_gamertag,
        COALESCE(SUM(((CASE WHEN SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),3,1) = "M" THEN CAST(SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),1,2) AS INT64)
                     ELSE CAST(SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),1,1) AS INT64)
                     END)*60 + (CASE WHEN (CASE WHEN SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),3,1) = "M" THEN CAST(SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),1,2) AS INT64)
                     ELSE CAST(SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),1,1) AS INT64)
                     END) >= 10 AND SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),5,1) = "." THEN CAST(SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),4,1) AS INT64)
                     WHEN (CASE WHEN SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),3,1) = "M" THEN CAST(SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),1,2) AS INT64)
                     ELSE CAST(SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),1,1) AS INT64)
                     END) >= 10 AND SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),6,1) = "." THEN CAST(SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),4,2) AS INT64)
                     WHEN (CASE WHEN SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),3,1) = "M" THEN CAST(SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),1,2) AS INT64)
                     ELSE CAST(SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),1,1) AS INT64)
                     END) < 10 AND SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),4,1) = "." THEN CAST(SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),3,1) AS INT64)
                     WHEN (CASE WHEN SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),3,1) = "M" THEN CAST(SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),1,2) AS INT64)
                     ELSE CAST(SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),1,1) AS INT64)
                     END) < 10 AND SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),5,1) = "." THEN CAST(SUBSTR((LTRIM(JSON_EXTRACT_SCALAR(matches.Results,"$.MatchDuration"),"PT")),3,2) AS INT64)
                     ELSE NULL
                     END))/60.0 ), 0) AS matches_sum_match_duration_in_minutes
      FROM halo_5_dataset.matches  AS matches
      GROUP BY 1,2,3
      ORDER BY 2 DESC
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
