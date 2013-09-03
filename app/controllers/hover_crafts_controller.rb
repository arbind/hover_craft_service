class HoverCraftsController < ApplicationController
  before_action :set_hover_craft, only: [:show, :edit, :update, :destroy]

  # GET /hover_crafts
  def index
    @hover_crafts = HoverCraft.all
  end

  # GET /hover_crafts/1
  def show
  end

  # GET /hover_crafts/new
  def new
    @hover_craft = HoverCraft.new
  end

  # GET /hover_crafts/1/edit
  def edit
  end

  # POST /hover_crafts
  def create
    @hover_craft = HoverCraft.new(hover_craft_params)

    if @hover_craft.save
      redirect_to @hover_craft, notice: 'Hover craft was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /hover_crafts/1
  def update
    if @hover_craft.update(hover_craft_params)
      redirect_to @hover_craft, notice: 'Hover craft was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /hover_crafts/1
  def destroy
    @hover_craft.destroy
    redirect_to hover_crafts_url, notice: 'Hover craft was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hover_craft
      @hover_craft = HoverCraft.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def hover_craft_params
      params[:hover_craft]
    end
end
