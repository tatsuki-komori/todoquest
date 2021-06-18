require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require './models'

require 'date'

require 'json'

enable :sessions


get '/' do
    # 能力値
    @abilities = Ability.where(user_id: session[:user]).order(id: "ASC")
    @goals = Goal.where(user_id: session[:user]).order(id: "ASC")

    if session[:user]
        if !session[:current_goal]
            @current_goal = @goals.first
        else
            @current_goal = @goals.find(session[:current_goal])
        end
        
        if @current_goal
            @smallgoal = @current_goal.smallgoals.order(id: "ASC").where(achieve_smallgoal: false).last
        end
        
        if !session[:date]
            @tasks = Task.where(user_id: session[:user]).order(id: "ASC")
        elsif session[:date] == 0
            @tasks = Task.where(user_id: session[:user]).where(deadline_date: Date.today).order(id: "ASC")
        elsif session[:date] == 1
            @tasks = Task.where(user_id: session[:user]).where(deadline_date: (Date.today+1)).order(id: "ASC")
        else
            @tasks = Task.where(user_id: session[:user]).where.not("(deadline_date=?) OR (deadline_date=?)", Date.today, (Date.today + 1))
        end
    end
    
    erb :index
end

post '/select_current_goal/:id' do
    session[:current_goal] = params[:id]
    redirect request.referer
end

get '/signin' do
    erb :sign_in
end

get '/signup' do
    erb :sign_up
end

post '/signin' do
    user = User.find_by(mail: params[:mail])
    if user && user.authenticate(params[:password])
        session[:user] = user.id
    end
    redirect '/'
end

post '/signup' do
    @user = User.create(mail: params[:mail], password: params[:password], password_confirmation: params[:password_confirmation])
    if @user.persisted?
        session[:user] = @user.id
        Ability.create([
            {user_id: session[:user], name: '知力', color: 'blue'},
            {user_id: session[:user], name: '生活力', color: 'green'},
            {user_id: session[:user], name: '対人力', color: 'yellow'},
            {user_id: session[:user], name: '体力', color: 'red'},
            {user_id: session[:user], name: '徳', color: 'orange'}
        ])
    end
    redirect '/'
end

get '/signout' do
    session[:user] = nil
    redirect '/'
end

post '/new_task' do
    task = Task.create({
        user_id: session[:user], 
        body: params[:body], 
        deadline_date: params[:date]
    })
    if params[:ability_id]
        params[:ability_id].each do |ability_id|
            TaskAbility.create({
                task_id: task.id,
                ability_id: ability_id
            })
        end
    end
    redirect '/'
end

post '/complete_task/:id' do
    task = Task.find(params[:id])
    task.update({
        achieve_task: true,
        achieve_date: Date.today
    })
    task.task_abilities.each do |ta|
        ta.ability.point += 1
        ta.ability.save
    end
    
    redirect '/'
end

post '/edit_task/:id' do
    task = Task.find(params[:id])
    task.update({
        body: params[:body],
        deadline_date: params[:date]
    })
    if TaskAbility.find_by(task_id: task.id)
        TaskAbility.find_by(task_id: task.id).destroy
    end
    if params[:ability_id]
        params[:ability_id].each do |ability_id|
            TaskAbility.create({
                task_id: task.id,
                ability_id: ability_id
            })
        end
    end
    redirect '/'
end

post '/delete_task/:id' do
    Task.find(params[:id]).destroy
    redirect '/'
end

post '/task_filter_all' do
    session[:date] = nil
    redirect '/'
end

post '/task_filter_today' do
    session[:date] = 0
    redirect '/'
end

post '/task_filter_tomorrow' do
    session[:date] = 1
    redirect '/'
end

post '/task_filter_other' do
    session[:date] = 2
    redirect '/'
end

get '/abilities_analytics/:id' do
    @abilities = Ability.where(user_id: session[:user]).order(id: "ASC")
    tasks = Task.where(user_id: session[:user])
    
    @ap_today = Array.new(@abilities.length, 0)
    @abilities.each_with_index do |ability, idx|
        tasks.where(achieve_date: Date.today).each do |t|
            if t.task_abilities.find_by(ability_id: ability.id)
                @ap_today[idx] += 1
            end
        end
    end
    
    @ability_point = Array.new(30, 0)
    if params[:id] == 'all'
        for i in 0..(@ability_point.length)
            @ability_point[i] = tasks.where(achieve_date: (Date.today-30+i)).count
        end
    else
        for i in 0..(@ability_point.length)
            tasks.where(achieve_date: (Date.today-30+i)).each do |t|
                @ability_point[i] = t.task_abilities.where(ability_id: params[:id]).count
            end
        end
    end
    @ap_json = @ability_point.to_json
    
    unless session[:graph]
        session[:graph] = 'week'
    end
    
    erb :abilities_analytics
end

get '/goals' do
    @goals = Goal.where(user_id: session[:user]).order(id: "ASC")

    unless session[:obstacles_num]
        session[:obstacles_num] = 1
    end
    unless session[:measures_num]
        session[:measures_num] = 1
    end
    unless session[:small_goals_num]
        session[:small_goals_num] = 1
    end
    
    if !session[:current_goal]
        @current_goal = @goals.first
    else 
        @current_goal = @goals.find(session[:current_goal])
    end
    erb :goals
end

post '/goals/add_obstacles/:id' do
    if params[:id]=='inc'
        session[:obstacles_num] += 1
    elsif session[:obstacles_num] > 1
        session[:obstacles_num] -= 1
    end
    redirect '/goals'
end

post '/goals/add_measures/:id' do
    if params[:id] == 'inc'
        session[:measures_num] += 1
    elsif session[:measures_num] > 1
        session[:measures_num] -= 1
    end
    redirect '/goals'
end

post '/goals/add_small_goal/:id' do
    if params[:id] == 'inc'
        session[:small_goals_num] += 1
    elsif session[:small_goals_num] > 1
        session[:small_goals_num] -= 1
    end
    redirect '/goals'
end

post '/goals/create_goal' do
    goal = Goal.create({
        user_id: session[:user],
        goal_body: params[:goal_body],
        title_name: params[:goal_title],
        achieve_goal: false
    })
    
    params[:obstacles].each do |obstacle|
        Obstacle.create({
            goal_id: goal.id,
            obstacle_body: obstacle
        })
    end
    
    params[:measures].each do |measure|
        Measure.create({
            goal_id: goal.id,
            measure_body: measure
        })
    end
    
    params[:small_goals].each do |small_goal|
        Smallgoal.create({
            goal_id: goal.id,
            smallgoal_body: small_goal,
            achieve_smallgoal: false
        })
    end
    session[:obstacles_num] = 1
    session[:measures_num] = 1
    session[:small_goals_num] = 1
    
    redirect '/goals'
end

post '/complete_smallgoal/:id' do
    Smallgoal.find(params[:id]).update({
        achieve_smallgoal: true
    })
    redirect request.referer
end

post '/complete_goal/:id' do
    goal = Goal.find(params[:id])
    
    flag = true
    goal.smallgoals.each do |sg|
        if !sg.achieve_smallgoal
            flag = false
        end
    end
    if flag
        goal.update({
            achieve_goal: true
        })
    end
    redirect request.referer
end

post '/abilities_analytics/select_graph/:id' do
    session[:graph] = params[:id]
    redirect request.referer
end