class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: %i[ show edit update destroy ]

  # GET /projects or /projects.json
  def index
    @projects = current_projects
  end

  # GET /projects/1 or /projects/1.json
  def show
    @members = show_members
  end

  # GET /projects/new
  def new
    @project = current_user.projects.build
  end

  # GET /projects/1/edit
  def edit
    if not_admin?()
        redirect_to project_path, 
        alert: "
        You are without administrator rights"
    end
  end


  # POST /projects or /projects.json
  def create
    @project = current_user.projects.build(project_params)
    respond_to do |format|
      if @project.save
        current_user.add_role :creator, @project
        format.html { redirect_to project_url(@project), notice: "Project was successfully created." }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1 or /projects/1.json
  def update
    p params[:id]
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to project_url(@project), notice: "Project was successfully updated." }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1 or /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: "Project was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = current_projects.find_by(id: params[:id])
      
      redirect_to projects_path, notice: "Not Authorized To Edit This Project!" if @project.nil?
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.require(:project).permit(:name, :description, :file)
    end

    # Find projects that belong to them
    def current_projects
      Project.with_roles([:creator, :member, :member_admin], current_user)
    end

    def show_members 
        @project = Project.find(params[:id])
        User.with_any_role(:member, { name: :member, resource: @project }, { name: :member_admin, resource: @project })
    end

    def not_admin?
        current_user.has_role? :member, Project.find(params[:id])
    end
end
