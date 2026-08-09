class MessagesController < ApplicationController
  def create
    @room = Room.find(params[:room_id])
    @message = @room.messages.build(message_params)
    @message.user = Current.session.user

    if @message.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_message",
            partial: "messages/form",
            locals: { room: @room, message: Message.new }
          )
        end
        format.html { redirect_to @room }
      end
    else
      redirect_to @room, alert: "Could not save message."
    end
  end

  private
  def message_params
    params.require(:message).permit(:content)
  end
end
