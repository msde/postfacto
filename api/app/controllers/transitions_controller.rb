#
# Postfacto, a free, open-source and self-hosted retro tool aimed at helping
# remote teams.
#
# Copyright (C) 2016 - Present Pivotal Software, Inc.
#
# This program is free software: you can redistribute it and/or modify
#
# it under the terms of the GNU Affero General Public License as
#
# published by the Free Software Foundation, either version 3 of the
#
# License, or (at your option) any later version.
#
#
#
# This program is distributed in the hope that it will be useful,
#
# but WITHOUT ANY WARRANTY; without even the implied warranty of
#
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#
# GNU Affero General Public License for more details.
#
#
#
# You should have received a copy of the GNU Affero General Public License
#
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
class TransitionsController < ApplicationController
  before_action :load_retro, :authenticate_retro

  def transitions
    transition = params.require(:transition)

    if transition != 'NEXT'
      render json: :nothing, status: 400
      return
    end

    unless @retro.highlighted_item_id.nil?
      previous_item = @retro.items.find(@retro.highlighted_item_id)
      previous_item.done = true
      previous_item.save!
    end

    next_item = RetroFacilitator.new.facilitate(@retro).first

    if next_item.nil?
      @retro.highlighted_item_id = nil
    else
      @retro.highlighted_item_id = next_item.id
      @retro.retro_item_end_time = 5.minutes.from_now
    end

    @retro.save!
    RetrosChannel.broadcast(@retro)
    render 'retros/show'
  end
end
