ActiveRecord::Base.establish_connection

class User < ActiveRecord::Base
    has_secure_password
    validates :mail,
        presence: true,
        format: {with:/\A[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+\z/}
    validates :password,
        format: {with:/(?=.*?[a-z])(?=.*?[0-9])/},
        length: {in: 5..10}
        
    has_many :tasks
    has_many :abilities
    has_many :goals
end

class Task < ActiveRecord::Base
    belongs_to :user
    has_many :task_abilities
    has_many :abilities, through: :task_abilities
    has_many :task_projects
    has_many :projects, through: :task_projects
end

class TaskAbility < ActiveRecord::Base
    belongs_to :task, optional: true
    belongs_to :ability, optional: true
end

class Ability < ActiveRecord::Base
    belongs_to :user
    has_many :task_abilities
    has_many :tasks, through: :task_abilities
end

class Task_project < ActiveRecord::Base
    belongs_to :task
    belongs_to :project
end

class Project < ActiveRecord::Base
    has_many :task_projects
    has_many :tasks, through: :task_projects
end

class Goal < ActiveRecord::Base
    belongs_to :user
    has_many :obstacles
    has_many :measures
    has_many :smallgoals
end

class Obstacle < ActiveRecord::Base
    belongs_to :goals
end

class Measure < ActiveRecord::Base
    belongs_to :goals
end

class Smallgoal < ActiveRecord::Base
    belongs_to :goals
end