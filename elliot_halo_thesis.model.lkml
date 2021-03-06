connection: "halo_database_1"

# include all the views
include: "matches.view.lkml"
include: "matches_sessions.view.lkml"
include: "matches_test.view.lkml"
include: "metadata_csr_designations.view.lkml"
include: "metadata_maps.view.lkml"
include: "metadata_playlists.view.lkml"
include: "metadata_weapons.view.lkml"
include: "players.view.lkml"

datagroup: elliot_halo_thesis_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_for: "1 hour"

# persist_with: elliot_halo_thesis_default_datagroup

# explore: matches_avg_kill_death {}

explore: matches {
  persist_for: "30 minutes"
  join: players {
    type: left_outer
    sql_on: ${matches.compound_gamertag_playlistid} = ${players.primary_key_gamertag_playlistid} ;;
    relationship: many_to_one
  }

  join: metadata_playlists {

    type: left_outer
    sql_on: ${matches.playlist_id} = ${metadata_playlists.id} ;;
    relationship: many_to_one
  }

  join: metadata_maps {
    type: left_outer
    sql_on: ${matches.map_id} = ${metadata_maps.id} ;;
    relationship: many_to_one
  }

  join: metadata_weapons {
    type: left_outer
    sql_on: ${players.weapon_with_most_kills_id} = ${metadata_weapons.id} ;;
    relationship: many_to_one
  }

  join: metadata_csr_designations {
    type: left_outer
    sql_on: ${players.rank_class_id} = ${metadata_csr_designations.class_id} ;;
    relationship: many_to_one
  }

#   join: matches_avg_kill_death {
#     type: left_outer
#     sql_on: ${matches.compound_gamertag_playlistid} = ${matches_avg_kill_death.compound_gamertag_playlistid} ;;
#     relationship: many_to_one
#   }
}

explore: players {
  join: metadata_weapons {
    type: left_outer
    sql_on: ${players.weapon_with_most_kills_id} = ${metadata_weapons.id} ;;
    relationship: many_to_one
  }

  join: metadata_csr_designations {
    type: left_outer
    sql_on: ${players.rank_class_id} = ${metadata_csr_designations.class_id} ;;
    relationship: many_to_one
  }

  join: metadata_playlists {
    type: left_outer
    sql_on: ${players.playlist_id} = ${metadata_playlists.id} ;;
    relationship: many_to_one
  }
#
#   join: matches_avg_kill_death {
#     type: inner
#     sql_on: ${players.primary_key_gamertag_playlistid} = ${matches_avg_kill_death.compound_gamertag_playlistid} ;;
#     relationship: one_to_one
#   }
}

##########################

explore: metadata_playlists {}

explore: metadata_maps {}

explore: metadata_csr_designations {}

##########################
