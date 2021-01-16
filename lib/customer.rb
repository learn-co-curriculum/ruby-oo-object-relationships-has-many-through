require 'pry'

class Customer
    attr_accessor :name, :age

    @@all = []

    def initialize(name, age)
        @name = name
        @age = age

        @@all.push(self)
    end

    def new_meal(waiter, total, tip)
        Meal.new(waiter, self, total, tip)
    end

    def meals
        # binding.pry
        Meal.all.select {|meals| meals.customer == self}
    end

    def waiters
        meals.map {|waiters| waiters.waiter}
    end

    def self.all
        @@all
    end
end