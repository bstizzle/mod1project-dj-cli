class CLI

    @@username_database = {}

    def check_answer(answer)
        if answer == "Yes"
            puts "Please enter your username:"
            username = gets.chomp
            authenticate_username(username)
        else
            puts "Please enter a new username:"
            username = gets.chomp
            setup_username(username)
        end
    end

    def setup_username(username)
        if @@username_database.key?(username)
            puts "Oops! That name is already taken."
            sleep(1)
            puts "Please enter another username:"
            new_username = gets.chomp
            setup_username(new_username)
        else
            @@username_database[username] = ""
            puts "Please enter a password:"
            password = gets.chomp
            @@username_database[username] = password
        end
    end

    def authenticate_username(username)
        if @@username_database.key?(username)
            puts "Please enter your password:"
            password = gets.chomp
            authenticate_password(username, password)
        else
            puts "We don't recognize that username. Please re-enter your username:"
            username = gets.chomp
            authenticate_username(username)
        end
    end
    
    def authenticate_password(username, password)
        if @@username_database[username] == password
            puts "Welcome back!"
        else
            puts "We don't recognize that password. Please re-enter your password:"
            new_password = gets.chomp
            authenticate_username(username, new_password)
        end
    end

end