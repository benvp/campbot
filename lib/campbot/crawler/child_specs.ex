defmodule Campbot.Crawler.ChildSpecs do
  def all do
    [
      # Grand canyon
      Supervisor.child_spec(
        {Campbot.Crawler.Job, name: Campbot.Crawler.Job_Mather_1, park_id: "70971", date: "5/9/2018"},
        id: {Campbot.Crawler.Job, 1}
      ),
      Supervisor.child_spec(
        {Campbot.Crawler.Job, name: Campbot.Crawler.Job_Mather_2, park_id: "70971", date: "5/10/2018"},
        id: {Campbot.Crawler.Job, 2}
      ),
      Supervisor.child_spec(
        {Campbot.Crawler.Job, name: Campbot.Crawler.Job_Mather_3, park_id: "70971", date: "5/11/2018"},
        id: {Campbot.Crawler.Job, 3}
      ),
      # Yosemite
      Supervisor.child_spec(
        {Campbot.Crawler.Job, name: Campbot.Crawler.Job_NorthPines_1, park_id: "70927", date: "5/21/2018"},
        id: {Campbot.Crawler.Job, 4}
      ),
      Supervisor.child_spec(
        {Campbot.Crawler.Job, name: Campbot.Crawler.Job_NorthPines_2, park_id: "70927", date: "5/22/2018"},
        id: {Campbot.Crawler.Job, 5}
      ),
      Supervisor.child_spec(
        {Campbot.Crawler.Job, name: Campbot.Crawler.Job_LowerPines_1, park_id: "70928", date: "5/21/2018"},
        id: {Campbot.Crawler.Job, 6}
      ),
      Supervisor.child_spec(
        {Campbot.Crawler.Job, name: Campbot.Crawler.Job_LowerPines_2, park_id: "70928", date: "5/22/2018"},
        id: {Campbot.Crawler.Job, 7}
      ),
      Supervisor.child_spec(
        {Campbot.Crawler.Job, name: Campbot.Crawler.Job_UpperPines_1, park_id: "70925", date: "5/21/2018"},
        id: {Campbot.Crawler.Job, 8}
      ),
      Supervisor.child_spec(
        {Campbot.Crawler.Job, name: Campbot.Crawler.Job_UpperPines_2, park_id: "70925", date: "5/22/2018"},
        id: {Campbot.Crawler.Job, 9}
      ),
      # Bryce Canyon
      Supervisor.child_spec(
        {Campbot.Crawler.Job, name: Campbot.Crawler.Job_NorthCampground_3, park_id: "74065", date: "5/15/2018"},
        id: {Campbot.Crawler.Job, 12}
      ),
      Supervisor.child_spec(
        {Campbot.Crawler.Job, name: Campbot.Crawler.Job_SunsetCampground_1, park_id: "74088", date: "5/13/2018"},
        id: {Campbot.Crawler.Job, 13}
      ),
      Supervisor.child_spec(
        {Campbot.Crawler.Job, name: Campbot.Crawler.Job_SunsetCampground_2, park_id: "74088", date: "5/14/2018"},
        id: {Campbot.Crawler.Job, 14}
      ),
      Supervisor.child_spec(
        {Campbot.Crawler.Job, name: Campbot.Crawler.Job_SunsetCampground_3, park_id: "74088", date: "5/15/2018"},
        id: {Campbot.Crawler.Job, 15}
      ),
      # Sequioa
      Supervisor.child_spec(
        {Campbot.Crawler.Job, name: Campbot.Crawler.Lodgepole_1, park_id: "70941", date: "5/19/2018"},
        id: {Campbot.Crawler.Job, 16}
      ),
      Supervisor.child_spec(
        {Campbot.Crawler.Job, name: Campbot.Crawler.Lodgepole_2, park_id: "70941", date: "5/20/2018"},
        id: {Campbot.Crawler.Job, 17}
      )
    ]
  end
end
