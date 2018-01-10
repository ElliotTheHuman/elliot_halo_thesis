view: matches {
  sql_table_name: halo_5_dataset.matches ;;

  ############ JSON BLOBS ############

  dimension: results {
    type: string
    hidden: yes
    sql: ${TABLE}.Results ;;
  }

  ############ DIMENSIONS ############

  dimension: compound_gamertag_playlistid {
    hidden: yes
    sql: CONCAT(${gamertag},' ',${playlist_id}) ;;
  }

  dimension: season_id {
    type: string
    sql: JSON_EXTRACT_SCALAR(${results},"$.SeasonId") ;;
  }

  dimension: match_id {
    type: string
    sql: JSON_EXTRACT_SCALAR(${results},"$.Id.MatchId") ;;
    primary_key: yes
  }

  dimension: map_id {
    type: string
    sql: JSON_EXTRACT_SCALAR(${results},"$.MapId") ;;
  }

  dimension: playlist_id {
    type: string
    sql: JSON_EXTRACT_SCALAR(${results},"$.HopperId") ;;
  }

  dimension: gamertag {
    type: string
    sql: JSON_EXTRACT_SCALAR(${results},"$.Players[0].Player.Gamertag") ;;
    drill_fields: [match_id]
  }

  dimension: match_rank {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.Players[0].Rank") AS FLOAT64) ;;
  }

  dimension: match_result_code {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.Players[0].Result") AS INT64) ;;
    hidden: yes
  }

  dimension: match_result {
    type: string
    sql: CASE WHEN ${match_result_code} = 3 THEN "Win"
              ELSE "Loss"
              END ;;
  }

  dimension: kills {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.Players[0].TotalKills") AS INT64) ;;
  }

  dimension: deaths {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.Players[0].TotalDeaths") AS INT64) ;;
  }

  dimension: assists {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.Players[0].TotalAssists") AS INT64) ;;
  }

  # GOING IN A PDT
  dimension: kill_death_ratio {
    type: number
    sql: CASE WHEN ${deaths} = 0 THEN ${kills}*1.0/1
              ELSE ${kills}*1.0/${deaths}
              END ;;
    value_format: "0.00"
  }

  # GOING IN A PDT
  dimension: kill_death_assist_spread {
    type: number
    sql: ${kills} + (1/3)*${assists} - ${deaths};;
    value_format: "0.00"
  }

  dimension_group: match_completed_date {
    type: time
    timeframes: [date,day_of_week]
    datatype: date
    sql: TIMESTAMP(JSON_EXTRACT_SCALAR(${results},"$.MatchCompletedDate.ISO8601Date"));;
  }

  # GOIGN IN A PDT
  dimension: match_duration_raw {
    type: string
    sql: LTRIM(JSON_EXTRACT_SCALAR(${results},"$.MatchDuration"),"PT") ;;
    hidden: yes
  }

  # GOING IN A PDT
  dimension: match_duration_minutes_raw {
    type: number
    sql:  CASE WHEN SUBSTR(${match_duration_raw},3,1) = "M" THEN CAST(SUBSTR(${match_duration_raw},1,2) AS INT64)
               ELSE CAST(SUBSTR(${match_duration_raw},1,1) AS INT64)
               END ;;
    hidden: yes
  }

  # GOING IN A PDT
  dimension: match_duration_seconds_raw {
    type: number
    sql:  CASE WHEN ${match_duration_minutes_raw} >= 10 AND SUBSTR(${match_duration_raw},5,1) = "." THEN CAST(SUBSTR(${match_duration_raw},4,1) AS INT64)
               WHEN ${match_duration_minutes_raw} >= 10 AND SUBSTR(${match_duration_raw},6,1) = "." THEN CAST(SUBSTR(${match_duration_raw},4,2) AS INT64)
               WHEN ${match_duration_minutes_raw} < 10 AND SUBSTR(${match_duration_raw},4,1) = "." THEN CAST(SUBSTR(${match_duration_raw},3,1) AS INT64)
               WHEN ${match_duration_minutes_raw} < 10 AND SUBSTR(${match_duration_raw},5,1) = "." THEN CAST(SUBSTR(${match_duration_raw},3,2) AS INT64)
               ELSE NULL
               END ;;
    hidden: yes
  }

  dimension: match_duration_actual {
    alias: [match_duration]
    type: number
    sql: ${match_duration_minutes_raw}*60 + ${match_duration_seconds_raw} ;;
  }

  ############ MEASURES ############

  measure: count {
    type: count
  }

  measure: average_kill_death_ratio  {
    type: average
    sql: ${kill_death_ratio} ;;
    value_format: "0.00"
  }

  measure: average_match_rank {
    type: average
    sql: ${match_rank} ;;
    value_format: "0.00"
  }

  measure: average_match_duration {
    type: average
    sql: ${match_duration_actual} ;;
  }
}
