class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy]

  def index
    if params[:query].present?
      @scoped = policy_scope(Task)
      query = 'title LIKE :query OR details LIKE :query'
      @tasks = @scoped.where(query, query: "%#{params[:query]}%")
    else
      @tasks = policy_scope(Task)
    end
    @done = @tasks.where(completed: 1)
    @progress = (@done.length.to_f / @tasks.length) * 100
  end

  def show
    authorize @task
  end

  def new
    @task = Task.new
    @groups = policy_scope(Group)
    authorize @task
  end

  def create
    @task = Task.new(task_params)
    @task.user = current_user
    authorize @task
    if @task.save
      redirect_to tasks_path(@task)
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
    @groups = policy_scope(Group)
    authorize @task
  end

  def update
    authorize @task
    if @task.update(task_params)
      redirect_to tasks_path(@task)
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    authorize @task
    @task.destroy
    redirect_to tasks_path
  end

  private

  def task_params
    params.require(:task).permit(:title, :details, :completed, :priority,:group_id)
  end

  def set_task
    @task = Task.find(params[:id])
  end
end
