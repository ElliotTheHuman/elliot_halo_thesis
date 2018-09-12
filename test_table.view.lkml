# If necessary, uncomment the line below to include explore_source.
# include: "matches_avg_kill_death.view.lkml"

view: test_table {
  derived_table: {
    explore_source: matches_avg_kill_death {
      column: gamertag {}
    }
  }

  dimension: gamertag {}
}
