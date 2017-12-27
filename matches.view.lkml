view: matches {
  sql_table_name: halo_5_dataset.matches ;;

  ############ JSON BLOBS ############

  dimension: results {
    type: string
    hidden: yes
    sql: ${TABLE}.Results ;;
  }

  ############ DIMENSIONS ############

  dimension: primary_key_gamertag_playlistid {
    hidden: yes
    sql: CONCAT(${gamertag},' ',${playlist_id}) ;;
  }

  dimension: season_id {
    type: string
    sql: JSON_EXTRACT_SCALAR(${results},"$.SeasonId") ;;
  }

  dimension: match_id {
    type: string
    sql: JSON_EXTRACT_SCALAR(${results},"$.Id.MatchId");;
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
    sql: JSON_EXTRACT_SCALAR(${results},"$.Players[0].Player.Gamertag");;
  }

  dimension: match_rank {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.Players[0].Rank") AS FLOAT64);;
  }

  dimension: kills {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.Players[0].TotalKills") AS FLOAT64) ;;
  }

  dimension: deaths {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.Players[0].TotalDeaths") AS FLOAT64) ;;
  }

  dimension: assists {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.Players[0].TotalAssists") AS FLOAT64) ;;
  }

  dimension_group: match_completed_date {
    type: time
    timeframes: [date,day_of_week]
    datatype: date
    sql: TIMESTAMP(JSON_EXTRACT_SCALAR(${results},"$.MatchCompletedDate.ISO8601Date"));;
  }

  dimension: match_duration {
    type: string
    sql: TIMESTAMP(JSON_EXTRACT_SCALAR(${results},"$.MatchDuration"));;
  }

  dimension: kill_death_ratio {
    type: number
    sql: CASE WHEN ${deaths} = 0 THEN ${kills}*1.0/1
              ELSE ${kills}*1.0/${deaths}
              END;;
    value_format: "0.00"
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

}
