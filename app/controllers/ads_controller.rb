class AdsController < ApplicationController
    before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :archive, :unarchive]
    before_action :ad_owner, only: [:edit, :update, :archive, :unarchive]

    def index
        if params[:ad] && ad_params[:category_id].present? # Filtering by category
            @ads = Ad.where(category_id: ad_params[:category_id]).paginate(page: params[:page])
        else
            @ads = Ad.paginate(page: params[:page])
        end
    end

    def show
        @ad = Ad.find(params[:id])
    end

    def new
        @ad = Ad.new
    end

    def create
        @ad = current_user.ads.build(title: ad_params[:title], text: ad_params[:text])
        @ad.category = Category.find(ad_params[:category_id])
        if @ad.save
            ad_params[:tag_ids].each do |tag_id|
                unless tag_id.empty?
                    AdTag.create!(ad_id: @ad.id, tag_id: tag_id.to_i)
                end
            end
            flash[:success] = "Ad posted!"
            redirect_to @ad
        else
            render 'new'
        end
    end

    def edit
        @ad = Ad.find(params[:id])
    end

    def update
        @ad = Ad.find(params[:id])
        if @ad.update(ad_params)
            flash[:success] = "Ad updated"
            redirect_to @ad
        else
            render 'edit'
        end
    end

    def destroy
        Ad.find(params[:id]).destroy
        flash[:success] = "Ad deleted"
        redirect_to ads_url
    end

    def archive
        @ad = Ad.find(params[:id])
        @ad.archived = true
        @ad.save!
        flash[:success] = "Ad has been archived"
        redirect_to @ad
    end

    def unarchive
        @ad = Ad.find(params[:id])
        @ad.archived = false
        @ad.save!
        flash[:success] = "Ad has been unarchived"
        redirect_to @ad
    end

    private
        def ad_params
            params.require(:ad).permit(:title, :text, :category_id, :tag_ids => [])
        end

        def ad_owner
            @ad = Ad.find(params[:id])
            redirect_to(root_path) unless current_user == @ad.user
        end
end
