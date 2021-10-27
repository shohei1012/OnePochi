require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cookies'
require 'pg'
require 'date'
require 'time'


enable :sessions
# date = DateTime.now 
time = Time.now 
# flash[:danger] = "登録されていません。"

client = PG::connect(
    :host => "localhost",
    :user => ENV.fetch("USER", "heycha"), :password => '',
    :dbname => "product")


############
# ホーム画面 #
############

get '/index' do
    @comments = client.exec_params("SELECT comment FROM randoms").to_a
    return erb :index
end

get '/random' do  
    return erb :random
end
post '/random' do  
    comment = params[:comment]
    client.exec_params("INSERT INTO randoms (comment)
    VALUES ($1)",
    [comment]
    )     
    return redirect '/index'
end

##########
# 出勤画面 #
##########

get '/login_start_time' do
    return erb :login_start_time
end

post '/login_start_time' do
    user_no = params[:user_no]
    password = params[:password]
    user = client.exec_params("SELECT * FROM users WHERE  user_no = $1 AND password = $2 LIMIT 1",
        [user_no, password]
    ).to_a.first
    
    if user.nil?
        return erb :login_start_time
    else
        session[:user] = user 
        # データベースへ挿入
        user_id = session[:user].fetch("id").to_i
        date = Date.today
        # date = params[:date]
        start_time = time.strftime("%-H時%-M分")
        start_comment = params[:start_comment]
        client.exec_params("INSERT INTO start_works (user_id, date, start_time, start_comment)
        VALUES ($1, $2, $3, $4)",
        [user_id, date, start_time, start_comment]
        )     
        return redirect "/index"
    end
end

#############
 # 退勤画面 #
#############

get '/login_end_time' do
    return erb :login_end_time
end

post '/login_end_time' do
    user_no = params[:user_no]
    password = params[:password]
    user = client.exec_params("SELECT * FROM users WHERE  user_no = $1 AND password = $2 LIMIT 1",
    [user_no, password]
    ).to_a.first

    if user.nil?
      return erb :login_end_time
    else
        session[:user] = user 
        # データベースへ挿入
        user_id = session[:user].fetch("id").to_i
        date = Date.today
        # date = params[:date]
        end_time = time.strftime("%-H時%-M分")
        end_comment = params[:end_comment]
        # binding.irb
        client.exec_params("INSERT INTO end_works (user_id, date, end_time, end_comment)
        VALUES ($1, $2, $3, $4)",
        [user_id, date, end_time, end_comment]
        )     
    end
    return redirect "/index"
end

################
 # 管理画面 #
################

get '/admin_login' do
    return erb :admin_login
end

post '/admin_login' do
    user_no = params[:user_no]
    password = params[:password]
    user = client.exec_params("SELECT * FROM users WHERE  user_no = $1 AND password = $2 AND auth_type = 1 LIMIT 1",
    [user_no, password]
    ).to_a.first

    if user.nil?
          return erb :admin_login
    else
        session[:user] = user 
        return redirect "/admin_user_list"
    end     
end

################
 # 社員リスト #
################

get '/admin_user_list' do
    @admin_name = session[:user].fetch("user_name")
    user_id = session[:user].fetch("id")
    @starts = client.exec_params("SELECT * FROM start_works WHERE user_id = $1 ",
        [user_id]
    )
    @ends = client.exec_params("SELECT * FROM end_works WHERE user_id = $1 ",
        [user_id]
    )
    return erb :admin_user_list
end

post '/admin_user_list' do
    user_id = params[:user_id]

    return redirect "/another_user_result/#{user_id}"
end


###################
 # 社員勤怠管理表 #
###################

get '/admin_user_result/:id' do
    user_id = @user_id
    @starts = client.exec_params("SELECT * FROM start_works WHERE user_id = $1 ",
        [user_id]
    )
    @ends = client.exec_params("SELECT * FROM end_works WHERE user_id = $1 ",
        [user_id]
    )
    return erb :admin_user_result
end


##################
 # 管理者ログアウト #
##################
delete '/signout' do
    session[:user] = nil
    redirect '/admin_login'
end

################
################
 # ダミーテーブル #
################
################
get '/another_user_result/1' do
    # user = client.exec_params("SELECT * FROM users LIMIT 1"
    # ).to_a
    #あらじゃい
    @user_name = "hasegawa"
    @starts = client.exec_params("SELECT * FROM start_works WHERE user_id = 1 ",
    )
    @ends = client.exec_params("SELECT * FROM end_works WHERE user_id = 1 ",
    )
    return erb :another_user_result
end
get '/another_user_result/2' do
    # user = client.exec_params("SELECT * FROM users LIMIT 1"
    # ).to_a
    #あらじゃい
    @user_name = "heycha"
    @starts = client.exec_params("SELECT * FROM start_works  WHERE user_id = 2 ",
    )
    @ends = client.exec_params("SELECT * FROM end_works WHERE user_id = 2",
    )
    return erb :another_user_result
end
get '/another_user_result/3' do
    # user = client.exec_params("SELECT * FROM users LIMIT 1"
    # ).to_a
    #あらじゃい
    @user_name = "蒲焼焼タロー"
    @starts = client.exec_params("SELECT * FROM start_works WHERE user_id = 3 ",
    )
    @ends = client.exec_params("SELECT * FROM end_works WHERE user_id = 3",
    )
    return erb :another_user_result
end