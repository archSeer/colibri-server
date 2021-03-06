defmodule Colibri.ArtistController do
  use Colibri.Web, :controller

  alias Colibri.Artist

  plug :scrub_params, "artist" when action in [:create, :update]

  def index(conn, _params) do
    artists = Repo.all(Artist)
    render(conn, :index, data: artists)
  end

  def create(conn, %{"artist" => artist_params}) do
    changeset = Artist.changeset(%Artist{}, artist_params)

    case Repo.insert(changeset) do
      {:ok, artist} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", artist_path(conn, :show, artist))
        |> render(:show, data: artist)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Colibri.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    artist = Repo.get!(Artist, id)
    render(conn, :show, artist: artist)
  end

  def update(conn, %{"id" => id, "artist" => artist_params}) do
    artist = Repo.get!(Artist, id)
    changeset = Artist.changeset(artist, artist_params)

    case Repo.update(changeset) do
      {:ok, artist} ->
        render(conn, :show, data: artist)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Colibri.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    artist = Repo.get!(Artist, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(artist)

    send_resp(conn, :no_content, "")
  end
end
