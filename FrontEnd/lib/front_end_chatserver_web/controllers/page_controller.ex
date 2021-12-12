defmodule FrontEndChatserverWeb.PageController do
  use FrontEndChatserverWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def loading(conn, _params) do
    render(conn, "loading.html")
  end

  def overview_chatrooms(conn, _params) do
    render(conn, "allchatrooms.html")
  end

  def overview_messages(conn, _params) do
    render(conn, "allmessages.html")
  end

  ########################################################################
  ##                              LOGS                                 ##
  ########################################################################

  def logs_short(conn, _) do
    data = FrontEndChatserver.LogDatabase.get_logs(:short) |> Jason.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> text(data)
  end

  def logs_full(conn, _) do
    data = FrontEndChatserver.LogDatabase.get_logs(:all) |> Jason.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> text(data)
  end


  ########################################################################
  ##                            CHATROOM                                ##
  ########################################################################

  def new_chatroom(conn, _params) do
    render(conn, "newchatroom.html")
  end

  def create_chatroom(conn, %{"chatroom_id" => chatroom_id}) do
    _unique_tag = FrontEndChatserver.ChatroomPublisher.create_chatroom(chatroom_id)
    conn
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def all_chatrooms(conn, %{}) do
    unique_tag = FrontEndChatserver.ChatroomPublisher.all_chatrooms()

    text(
      conn,
      "requested with tag #{unique_tag}, normally you should go to a loading page or have some javascript handle this..."
    )
  end

  def all_messages(conn, %{"chatroom_id" => chatroom_id}) do
    unique_tag = FrontEndChatserver.ChatroomPublisher.all_messages(chatroom_id)

    text(
      conn,
      "requested with tag #{unique_tag}, normally you should go to a loading page or have some javascript handle this..."
    )
  end


  ########################################################################
  ##                             CLIENTS                                ##
  ########################################################################

  def new_client(conn, _params) do
    render(conn, "newclient.html")
  end

  def create_client(conn, %{"client_id" => client_id}) do
    _unique_tag = FrontEndChatserver.ClientPublisher.create_client(client_id)
    conn
    |> redirect(to: Routes.page_path(conn, :index))
  end


  ########################################################################
  ##                        CLIENT & CHATROOM                           ##
  ########################################################################

  def new_participate(conn, _params) do
    render(conn, "newparticipate.html")
  end

  def new_sendmessage(conn, _params) do
    render(conn, "newsendmessage.html")
  end

  def participate_chatroom(conn, %{"chatroom_id" => chatroom_id, "client_id" => client_id}) do
    _unique_tag = FrontEndChatserver.ChatroomPublisher.participate_chatroom(chatroom_id, client_id)
    conn
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def send_message_in_chatroom(conn, %{"chatroom_id" => chatroom_id, "client_id" => client_id, "message" => message}) do
    FrontEndChatserver.ChatroomPublisher.send_message_in_chatroom(chatroom_id, client_id, message)
    conn
    |> redirect(to: Routes.page_path(conn, :index))
  end


end
