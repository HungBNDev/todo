class RoomsController < ApplicationController
  def index
    @rooms = Room.all
    @room = Room.new
  end

  def show
    @room = Room.find(params[:id])
    @message = Message.new
  end

  def create
    @room = Room.new(room_params)
    if @room.save
      redirect_to @room
    else
      @rooms = Room.all
      render :index, status: :unprocessable_entity
    end
  end

  private

  def room_params
    params.require(:room).permit(:name)
  end
end
