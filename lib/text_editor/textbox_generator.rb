module TextEditor
    module TextboxGenerator
        def create_textbox
            @page = Page.find_by(:id => params[:id], :type => params[:page_type])
            @textboxes = []
            @story = @page.story
            textbox = Textbox.create(:page => @page)
            @page.reload
            @textboxes = @page.textboxes
            respond_to do |format|
                format.html { }
                format.js { }
            end
        end

        def destroy_textbox
            @page = Page.find_by(:id => params[:page_id], :type => params[:page_type])
            @textbox = @page.textboxes.find_by_id(params[:id])
            @story = @page.story
            if @textbox && @textbox.destroy
                respond_to do |format|
                    format.html { render :page_editor}
                    format.js { render :page_editor }
                end
            end
        end

        def update_textbox
            @page = Page.find_by(:id => params[:page_id], :type => params[:page_type])
            textbox = @page.textboxes.find_by_id(params[:id])
            textbox.update(textbox_params)
            @story = @page.story
            @textbox_id = params[:id]
            respond_to do |format|
                format.html { render :page_editor }
                format.js { render :page_editor }
            end
        end

        def page_editor
            @page = Page.find_by_id(params[:id])
            @story = @page.story
            @textbox_id = params[:textbox_id]
            respond_to do |format|
                format.html { }
                format.js
            end
        end

	private
	def textbox_params
	  params.require(:textbox).permit(:textbox_width, :textbox_height, :textbox_position_top, :textbox_position_left, :background_color, :boundary)
	end
    end
end
