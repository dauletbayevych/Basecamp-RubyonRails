class MembersController < ApplicationController
    before_action :authenticate_user!

    def index
        @members = show_members
    end

    def show

    end

    def new
        @member = Role.new
        redirect_to projects_path
    end

    def edit
        user = User.find(changeRole[:id])
        project = Project.find(changeRole[:project_id])

        if (changeRole[:is_admin] == "1")
            user.remove_role :member, project 
            user.add_role :member_admin, project 
        else
            user.remove_role :member_admin, project 
            user.add_role :member, project 
        end

        redirect_to request.referer
    end

    def create
        @user = User.find_by(email: post_params[:email])
        project = Project.find(params[:project_id])

        return redirect_to request.referer, alert: "User with this name does not exist!" if @user.nil?
        
        if (@user.has_role? :member, project or 
            @user.has_role? :member_admin, project or 
            @user.has_role? :creator, project)
            redirect_to request.referer, alert: "User with this name already exist!"
        else
            if post_params[:is_admin] == '1'
                @user.add_role :member_admin, project
                redirect_to project_members_path
            else
                @user.add_role :member, project
                redirect_to project_members_path
            end
        end
    end

    def update
        redirect_to request.referer
    end

    def destroy
        user = User.find(destroy_params[:id])
        project = Project.find(destroy_params[:project_id])
        if(user.has_role? :member, project)
            user.remove_role :member, project 
        else
            user.remove_role :member_admin, project 
        end
        redirect_to request.referer
    end

    private

    def post_params
        params.require(:member).permit(:email, :is_admin)
    end

    def destroy_params
        params.require(:destroy).permit(:id, :project_id)
    end

    def changeRole
        params.require(:changeRole).permit(:id, :project_id, :is_admin)
    end
    
    def show_members 
        @project = Project.find(params[:project_id])
        User.with_any_role(:member, { name: :member, resource: @project }, { name: :member_admin, resource: @project })
    end
end