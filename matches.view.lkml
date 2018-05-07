include: "*.view.lkml"

view: matches {
  sql_table_name: halo_5_dataset.matches ;;
  set: drill_set_1 {
    fields: [
      metadata_playlists.name,
      metadata_maps.name,
      win_percentage
    ]
  }

  dimension: results {
    type: string
    hidden: yes
    sql: ${TABLE}.Results ;;
  }

############ DYNAMIC PERIOD ANALYSIS TEST ############

  filter: previous_period_filter {
    type: date
    description: "Use this filter for period analysis"
  }

  dimension: yesno_test {
    type: yesno
    sql: ${kills} > 10 ;;
  }


# SOMETHING ABOUT -1!

  dimension: previous_period {
    type: string
    description: "The reporting period as selected by the Previous Period Filter"
    sql:
      CASE
        WHEN {% date_start previous_period_filter %} is not null AND {% date_end previous_period_filter %} is not null /* date ranges or in the past x days */
          THEN
            CASE
              WHEN CAST(${match_completed_date_date} AS DATE) >=  CAST({% date_start previous_period_filter %} AS DATE)
                AND CAST(${match_completed_date_date} AS DATE) <= CAST({% date_end previous_period_filter %} AS DATE)
                THEN 'This Period'
              WHEN CAST(${match_completed_date_date} AS DATE) >= date_add(date_add(CAST({% date_start previous_period_filter %} AS DATE), INTERVAL -1 DAY), INTERVAL -1*date_diff(CAST({% date_end previous_period_filter %} AS DATE),CAST({% date_start previous_period_filter %} AS DATE), DAY) DAY)
                AND CAST(${match_completed_date_date} AS DATE) <= date_add(CAST({% date_start previous_period_filter %} AS DATE), INTERVAL -1 DAY)
                THEN 'Previous Period'
            END
          END ;;
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
    html: <a href="https://google.com"</a>  ;;
  }

  dimension: playlist_id {
    type: string
    sql: JSON_EXTRACT_SCALAR(${results},"$.HopperId") ;;
  }

  dimension: gamertag {
    type: string
    drill_fields: [match_result, winning_team_score, count]
    sql: JSON_EXTRACT_SCALAR(${results},"$.Players[0].Player.Gamertag");;
  }

  dimension: match_rank {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.Players[0].Rank") AS FLOAT64) ;;
  }

  dimension: tier_rank {
    type: tier
    sql: ${match_rank} ;;
    tiers: [4,8]
    style: relational
  }

  dimension: match_result_code {
    type: number
    sql: CAST(JSON_EXTRACT_SCALAR(${results},"$.Players[0].Result") AS INT64) ;;
    hidden: yes
  }

  dimension: match_result {
    type: string
    sql: CASE WHEN ${match_result_code} = 3 THEN "Win"
              WHEN ${match_result_code} = 2 THEN "Tie"
              WHEN ${match_result_code} = 1 THEN "Loss"
              ELSE "DNF"
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
  dimension: kill_death_plus_minus {
    type: number
    sql: ${kills} - ${deaths};;
    value_format: "0.00"
  }

  dimension_group: match_completed_date {
    type: time
    datatype: date
    timeframes: [date,day_of_week,week,month,raw]
    sql: EXTRACT(DATE FROM CAST(JSON_EXTRACT_SCALAR(${results},"$.MatchCompletedDate.ISO8601Date") AS TIMESTAMP));;
  }

  dimension: match_as_string {
    type: string
    sql: CAST(${match_completed_date_date} AS STRING) ;;
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
    label: "Match Duration"
    type: number
    sql: ${match_duration_minutes_raw}*60 + ${match_duration_seconds_raw} ;;
  }

  dimension: is_team_game {
    type: string
    sql: JSON_EXTRACT_SCALAR(${results},"$.IsTeamGame") ;;
    hidden: yes
  }

  dimension: winning_team_score {
    description: "Null if not a team-based mode"
    type: number
    sql: CASE WHEN ${is_team_game} = "true" AND JSON_EXTRACT_SCALAR(${results},"$.Teams[0].Rank") = "1"
                  THEN CAST(JSON_EXTRACT_SCALAR(${results},"$.Teams[0].Score") AS INT64)
              WHEN ${is_team_game} = "true" AND JSON_EXTRACT_SCALAR(${results},"$.Teams[1].Rank") = "1"
                  THEN CAST(JSON_EXTRACT_SCALAR(${results},"$.Teams[1].Score") AS INT64)
              ELSE NULL
              END ;;
    group_label: "Team Scores"
  }

  dimension: losing_team_score {
    description: "Null if not a team-based mode"
    type: number
    sql: CASE WHEN ${is_team_game} = "true" AND JSON_EXTRACT_SCALAR(${results},"$.Teams[0].Rank") = "2"
                  THEN CAST(JSON_EXTRACT_SCALAR(${results},"$.Teams[0].Score") AS INT64)
              WHEN ${is_team_game} = "true" AND JSON_EXTRACT_SCALAR(${results},"$.Teams[1].Rank") = "2"
                  THEN CAST(JSON_EXTRACT_SCALAR(${results},"$.Teams[1].Score") AS INT64)
              ELSE NULL
              END ;;
    group_label: "Team Scores"
  }

  dimension: team_score_spread {
    type: number
    sql: ${winning_team_score} - ${losing_team_score} ;;
  }

  ############ MEASURES ############

  measure: count {
    type: count
    drill_fields: [match_id, players.gamertag, kills, assists, deaths]
    description: "Hello it's me!"
  }


  measure: team_game_count {
    type: count
    filters: {
      field: is_team_game
      value: "yes"
    }
  }

  measure: count_of_DNFs {
    type: count
    drill_fields: [metadata_playlists.name, matches.count]
    filters: {
      field: match_result
      value: "DNF"
    }
  }

  measure: average_kills {
    type: average
    sql: ${kills} ;;
    value_format: "0.00"
  }

  measure: average_deaths {
    type: average
    sql: ${deaths} ;;
    value_format: "0.00"
  }

  measure: average_assists {
    type: average
    sql: ${assists} ;;
    value_format: "0.00"
  }

  measure: average_kill_death_ratio  {
    type: average
    sql: ${kill_death_ratio} ;;
    value_format: "0.00"
    drill_fields: [players.gamertag, match_id, metadata_playlists.name, kills, assists, deaths]
  }

  measure: average_kill_death_plus_minus {
    type: average
    sql: ${kill_death_plus_minus} ;;
    value_format: "0.00"
    drill_fields: [players.gamertag, match_id, metadata_playlists.name, kills, assists, deaths]
  }

  measure: average_winning_team_score {
    type: average
    sql: ${winning_team_score} ;;
    filters: {
      field: winning_team_score
      value: "< 400000000"
    }
    group_label: "Average Team Scores"
    value_format_name: decimal_2
  }

  measure: average_losing_team_score {
    type: average
    sql: ${losing_team_score} ;;
    filters: {
      field: losing_team_score
      value: "< 4000000000"
    }
    group_label: "Average Team Scores"
    value_format_name: decimal_2

    drill_fields: [losing_team_score]
  }

  measure: average_team_score_spread {
    type: average
    sql: ${team_score_spread} ;;
    filters: {
      field: losing_team_score
      value: "< 4000000000"
    }
    filters: {
      field: winning_team_score
      value: "< 4000000000"
    }
    group_label: "Average Team Scores"
    value_format_name: decimal_2
  }

  measure: average_match_rank {
    type: average
    sql: ${match_rank} ;;
    value_format: "0.00"
  }

  measure: average_match_duration {
    type: average
    sql: ${match_duration_actual} ;;
    value_format: "0.00"
  }

  measure: sum_match_duration_in_minutes {
    type: sum
    sql: ${match_duration_actual}/60.0 ;;
  }

  measure: percent_of_total {
    type: percent_of_total
    sql: ${count} ;;
  }

  measure: percent_of_Did_Not_Finishes {
    type: number
    sql: ${count_of_DNFs}/${count} ;;
    value_format_name: percent_2
    # Drill field idea: Hey, how many of these did not finishes come from different places?
    drill_fields: [metadata_playlist.name,matches.count]
  }

  measure: count_of_wins {
    hidden: yes
    type: count
    filters: {
      field: match_result
      value: "Win"
    }
  }

  measure: win_percentage {
    type: number
    sql: ${count_of_wins}/${count} ;;
    value_format_name: percent_2
  }

  measure: test {
    type: count_distinct
    sql: ${gamertag} ;;
    filters: {
      field: results
      value: "hey"
    }
    filters:  {
      field: results
      value: "listen"
    }
  }
}
