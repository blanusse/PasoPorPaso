
declare variable $season_info := doc("data/season_info.xml");
declare variable $season_standings := doc("data/season_standings.xml");

<handball_data>
  <season>
    <name>{ $season_info/season_info/season/@name/string() }</name>
    <year>{ $season_info/season_info/season/@year/string() }</year>
    <category>{ $season_info/season_info/season/category/@name/string() }</category>
    <gender>{ $season_info/season_info/season/competition/@gender/string() }</gender>
  </season>

  <competitors>
    {
      for $standing in $season_standings//season_standing[@type = "total"]//group
      let $group_name := $standing/@name/string()
      let $group_code := $standing/@group_name/string()
      for $s in $standing//standing
      let $c := $s/competitor
      return
        <competitor name="{ $c/@name }" country="{ $c/@country }">
          <standings>
            <standing
              group_name="{ $group_name }"
              group_name_code="{ $group_code }"
              rank="{ $s/@rank }"
              played="{ $s/@played }"
              win="{ $s/@win }"
              loss="{ $s/@loss }"
              draw="{ $s/@draw }"
              goals_for="{ $s/@goals_for }"
              goals_against="{ $s/@goals_against }"
              goals_diff="{ $s/@goals_diff }"
              points="{ $s/@points }"
            > </standing>
          </standings>
        </competitor>
    }
  </competitors>
</handball_data>
