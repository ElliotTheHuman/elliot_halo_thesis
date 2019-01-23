include: "*.view.lkml"

explore: matches_avg_kill_death {}

# Using this PDT to do expensive calcs and to do measures of measures
view: matches_avg_kill_death {
  derived_table: {
    sql:
      SELECT
        eawiofneiurngiueriufbns  ;;

    sql_trigger_value: SELECT 1 ;;
  }

  dimension: compound_gamertag_playlistid {
    hidden: yes
    sql: CONCAT(${TABLE}.gamertag,' ',${TABLE}.playlist_id) ;;
    primary_key: yes
  }

  dimension: gamertag {
    type: string
    sql: ${TABLE}.gamertag ;;
  }

  dimension: playlist_id {
    type: string
    sql: ${TABLE}.playlist_id ;;
  }

  dimension: average_kill_death_ratio_over_matches  {
    type: number
    sql: ${TABLE}.average_kill_death_ratio_over_matches ;;
    value_format: "0.00"
  }

  dimension: tier_rank {
    type: tier
    sql: ${average_kill_death_ratio_over_matches} ;;
    tiers: [1,2]
    style:  classic
  }

  measure: max_average_kilL_death_ratio_over_matches {
    type: max
    sql: ${average_kill_death_ratio_over_matches} ;;
    value_format: "0.00"
    drill_fields: [gamertag]
  }
}
