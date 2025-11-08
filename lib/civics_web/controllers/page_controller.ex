defmodule CivicsWeb.PageController do
  use CivicsWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home)
  end

  def geocode(conn, params) do
    address_search_query = params["q"] || ""

    assessments = Civics.Properties.geocode(address_search_query, 10)
    render(conn, :index, assessments: assessments)
  end

  def assessments(conn, params) do
    address_search_query = params["q"] || ""
    limit = params["limit"] || ""

    assessments = Civics.Properties.search_assessments(address_search_query, limit: limit)
    render(conn, :index, assessments: assessments)
  end

  def neighborhood_random(conn, _params) do
    neighborhood = Civics.Geo.Neighborhood.random()
    render(conn, :show_neighborhood, neighborhood: neighborhood)
  end
end
