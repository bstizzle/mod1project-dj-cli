class CLI

    username_database = []

    def authenticate_username(username)
        if username in username_database
            puts "Please enter your password:"
            password = gets.chomp
            authenticate_password(password)
        else
            puts "We don't recognize that username. Please try again"
            username = gets.chomp
            authenticate_username
        end
    end
    
end