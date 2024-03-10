defmodule Civics.Properties do
  @moduledoc """
  The Properties context.
  """

  import Ecto.Query, warn: false
  alias Civics.Repo

  alias Civics.Properties.Assessment
  alias Civics.Properties.AssessmentFts

  @doc """
  Returns the list of assessments.

  ## Examples

      iex> list_assessments()
      [%Assessment{}, ...]

  """
  def list_assessments do
    Repo.all(Assessment)
  end

  @doc """
  Gets a single assessment.

  Raises `Ecto.NoResultsError` if the Assessment does not exist.

  ## Examples

      iex> get_assessment!(123)
      %Assessment{}

      iex> get_assessment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_assessment!(id), do: Repo.get!(Assessment, id)
  def get_assessment_by_tax_key!(tax_key), do: Repo.get_by!(Assessment, tax_key: tax_key)

  def search_assessments(address_query) do
    formatted_query = format_query(address_query)

    query =
      from(a in Assessment,
        limit: 100
      )

    if address_query == "" do
      from(a in query,
        order_by: [desc: a.assessed_total]
      )
    else
      from(a in query,
        where: fragment("full_address LIKE ?", ^formatted_query),
        join: af in AssessmentFts,
        on: af.tax_key == a.tax_key,
        select: a,
        order_by: [asc: af.rank]
      )
    end
    |> Repo.all()
  end

  defp format_query(query) do
    q =
      String.split(query, " ")
      |> Enum.join("%")

    "%#{q}%"
  end
end
