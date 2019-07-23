# Ruby Object Relations: Has-Many-Through

## Objectives

* Understand Has-Many-Through relationships
* Construct indirect relationships between models (Customers, Waiters, and Meals)
* Explore the concept of a 'joining' model
* Continue to write code using a Single Source of Truth

## Introduction

We've seen how objects can be related to one another directly when one object
contains a reference to another. This is the "has-many"/"belongs-to"
association, and is a direct relationship. For example, an artist may have many
songs or a book might have many reviews.

In addition to these one-to-one and one-to-many relationships, some
relationships also need something to join them together. For example, you don't
need to have a direct relationship with the pilot of a flight you're on. You
have a relationship with that flight (you're taking the flight after all), and
the pilot has a relationship with the flight (they're flying it). So you have a
relationship to that pilot _through_ the flight.

If you take more than one flight, you'll have these kinds of relationships with
more than one pilot, all still using your ticket as the middle man. The way we
refer to this is that each customer _has many_ pilots _through_ tickets.

Check out some more examples:

* A company that offers a network of doctors to their employees _through_ the
  company's insurance program
* A user on a popular media sharing site can have many "likes", that occur
  _through_ the pictures they post
* A Lyft driver that you are connected to _through_ the rides you've taken with
  them

In this lesson, we'll build out just such a relationship using waiters,
customers, and meals. A customer has many meals, and a customer has many waiters
_through_ those meals. Similarly, a waiter has many meals and has many customers
_through_ meals.

## Building Out Our Classes

Let's start by building out the `Customer` class and `Waiter` class.  We want to
make sure when building out classes, that there's something to store each
instance.  That is to say: the `Customer` class should know about every
`customer` instance that gets created.

```ruby
# ./lib/customer.rb
class Customer
  attr_accessor :name, :age

  @@all = []

  def initialize(name, age)
    @name = name
    @age = age
    @@all << self
  end

  def self.all
    @@all
  end

end
```

As you can see, each `customer` instance has a name and an age. Their name and
age are set upon initialization, and because we created an attribute accessor
for both, the customer can change their name or age. If we wanted to limit this
ability to read-only, we would create an attribute reader instead. The
`Customer` class also has a class variable that tracks every instance of
`customer` upon creation.

```ruby
# ./lib/waiter.rb
class Waiter

  attr_accessor :name, :yrs_experience

  @@all = []

  def initialize(name, yrs_experience)
    @name = name
    @yrs_experience = yrs_experience
    @@all << self
  end

  def self.all
    @@all
  end

end
```

Each instance of the `Waiter` class has a name and an attribute describing their
years of experience. Just like the `Customer` class, the `Waiter` class has a
class variable that stores every `waiter` instance upon initialization.

## The "Has-Many-Through" Relationship

In real life, as a customer, each time you go out to eat, you have a different
meal. Even if you order the same exact thing in the exact same restaurant, it's
a different instance of that meal. So it goes without saying that a customer can
have many meals.

It's a safe bet to assume that unless you only eat at one very small restaurant,
you'll have many different waiters as well. Not all at once of course, because
you only have one waiter per meal. So it could be said that your relationship
with the waiter is through your meal. The same could be said of the waiter's
relationship with each customer.

That's the essence of the `has-many-through` relationship.

## How Does That Work in Code?

Great question! The way we're going to structure this relationship is by setting
up our `Meal` class as a 'joining' model between our `Waiter` and our `Customer`
classes. And because we're obeying the `single source of truth`, we're going to
tell the `Meal` class to know all the details of each `meal` instance. That
includes not only the total cost and the tip (which defaults to 0) but also who
the `customer` and `waiter` were for each meal.

```ruby
# ./lib/meal.rb
class Meal

  attr_accessor :waiter, :customer, :total, :tip

  @@all = []

  def initialize(waiter, customer, total, tip=0)
    @waiter = waiter
    @customer = customer
    @total = total
    @tip = tip
    @@all << self
  end

  def self.all
    @@all
  end
end
```

That looks great! And even better, it's going to give both the `customer` and
`waiter` instances the ability to get all the information about the meal that
they need without having to store it themselves. Let's build some methods.

## Building on the Relationship

If you take a look at our `customer` right now, they aren't capable of doing
much. Let's change that and give them the ability to create a `meal`. To do
this, they'll need to take in an instance of a `waiter` and supply the `total`
and `tip`, which we'll have defaulted to 0 here as well:

```ruby
# ./lib/customer.rb

  def new_meal(waiter, total, tip=0)
    Meal.new(waiter, self, total, tip)
  end
```

As you can see, we don't need to take `customer` in as an argument, because
we're passing in `self` as a reference to the current instance of customer. This
method will allow us to create new meals as a `customer`, and automatically
associate each new `meal` with the `customer` that created it. We can do the
same thing for the `Waiter` class:

```ruby
# ./lib/waiter.rb

  def new_meal(customer, total, tip=0)
    Meal.new(self, customer, total, tip)
  end
```

Notice that the _parameters_ are different for the `new_meal` method are
different for `customer` and `waiter`, but the order of _arguments_ for
`Meal.new()` remains the same - a waiter, a customer, a total and a tip. Great!
Now we can create `waiters`, `customers` and `meals` to our heart's content.

```ruby
  sam = Customer.new("Sam", 27)
  pat = Waiter.new("Pat", 2)
  alex = Waiter.new("Alex", 5)

  sam.new_meal(pat, 50, 10) # A Customer creates a Meal, passing in a Waiter instance
  sam.new_meal(alex, 20, 3) # A Customer creates a Meal, passing in a Waiter instance
  pat.new_meal(sam, 30, 5) # A Waiter creates a Meal, passing in a Customer instance
```

**Reminder**: If you would like to practice creating these instances, you can
load these classes up using IRB. Run `irb` from this lesson's main directory,
then load up each class into the IRB environment by using `require_relative`:

```ruby
require_relative './lib/customer.rb'
require_relative './lib/meal.rb'
require_relative './lib/waiter.rb'
```

## Completing the Has-Many-Through Relationship

This is awesome, but it isn't done yet! To complete our goal of establishing a
has-many-through relationship, we need a way for our `customer` and `waiter`
instances to get information about each other. The only way they can get that
information is through the meals they've created.

Relating this to real life, we can imagine a situation where a waiter might want
to know who their regular customers are and what meals those customers usually
order. Or, a customer might want to know the name of the waiter of their last
meal so they can leave a good review. To get our waiters and customers this
information, we're going to consult the `Meal` class _from_ the `Customer` and
`Waiter` classes. Let's start with the `Customer` class.

In plain English, the customer is going to look at all of the meals, and then
select only the ones that belong to them. Translated into code, that could be
written like the following:

```ruby
# ./lib/customer.rb

def meals
  Meal.all.select do |meal|
    meal.customer == self
  end
end
```

Boom. We're iterating through every instance of `Meal` and returning only the
ones where the meal's `customer` matches the current `customer` instance. If a
customer, Rachel, wants to know about all of her meals, all we need to do is call
the `#meals` method on the her Customer instance.

```ruby
alex = Customer.new("Alex", 30)
rachel = Customer.new("Rachel", 27)
dan = Waiter.new("Dan", 3)

rachel.new_meal(dan, 50, 10)
alex.new_meal(dan, 30, 5)

rachel.meals #=> [#<Meal:0x00007fa23f1575a0 @waiter=#<Waiter:0x00007fa23f14fbe8 @name="Dan", @yrs_experience=22>, @customer=#<Customer:0x00007fa240987468 @name="Rachel", @age=27>, @total=50, @tip=10>]
rachel.meals.length #=> 1

Meal.all.length #=> 2
```

Above, two meals were created, one for `rachel` and one for `alex`, both with the
same waiter. However, running `rachel.meals` only returns the meal `rachel` is
associated with.

So `rachel.meals` will return an array of all of Rachel's meals, but what if we now
want a list of all of the waiters that Rachel has interacted with?  Each meal is
also associated with a waiter, so to get every waiter from every meal Rachel has
had, we need to take the array of all of Rachel's meals, map over it, getting the
waiter from each of those meals.

Since we already have a `#meals` method to get an array of meals, we can reuse it
here and write a `#waiters` method like the following:

```ruby
# ./lib/customer.rb

def waiters
  meals.map do |meal|
    meal.waiter
  end
end
```

```ruby
terrance = Customer.new("Terrance", 27)
jason = Waiter.new("Jason", 4)
andrew = Waiter.new("Andrew", 7)
yomi = Waiter.new("Yomi", 10)

terrance.new_meal(jason, 50, 6)
terrance.new_meal(andrew, 60, 8)
terrance.new_meal(yomi, 30, 4)

terrance.waiters #=> [#<Waiter:0x00007fa23f18f860 @name="Jason", @yrs_experience=34>, #<Waiter:0x00007fa23f196818 @name="Andrew", @yrs_experience=27>, #<Waiter:0x00007fa23f19dd20 @name="Yomi", @yrs_experience=20>] 
terrance.waiters.length #=> 3
```

And to finish out first real-life example, if Terrance wanted to find the name of
his last waiter, we can use the `#waiters` method, then just get the `name` of the
last `waiter` in the Array.

```ruby
terrance.waiters.last.name #=> "Yomi"
```

To reinforce this concept, let's look at the same sort of relationship, but in
the other direction. This time, we will build out methods so a waiter
can find the customer that tips the the best.

Again to start, just like the customer, the waiter needs a way to get all the meals they have served. We'll create a `#meals` method again, with a subtle change:

```ruby
# ./lib/waiter.rb

def meals
  Meal.all.select do |meal|
    meal.waiter == self #checking for waiter now
  end
end
```

To find the best tipper, we can write another method, `#best_tipper`, use the
array we get from `#meals`, then return the customer of the meal with the
highest tip:

```ruby
# ./lib/waiter.rb

def best_tipper
  best_tipped_meal = meals.max do |meal_a, meal_b|
    meal_a.tip <=> meal_b.tip
  end

  best_tipped_meal.customer
end
```

```ruby
jason = Waiter.new("Jason", 4)
lisa = Customer.new("Lisa", 24)
tim = Customer.new("Tim", 35)
terrance = Customer.new("Terrance", 27)

terrance.new_meal(jason, 50, 3)
lisa.new_meal(jason, 40, 10)
tim.new_meal(jason, 45, 8)

jason.best_tipper #=> #<Customer:0x00007f80829959a8 @name="Lisa", @age=24>
jason.best_tipper.name #=> "Lisa"
```

And there you have it - customers have access to waiters, and waiters have
access to customers. Notice as well that neither the `Customer` class, nor the
`Waiter` class needed additional attributes - they don't need to keep track of
this information; they only need to have the methods that ask the write
questions - in this case to the `Meal` class, the _join_ between customer and
waiter.

## Conclusion

Why associate customers to waiter objects _through_ meals? By associating meals
to waiters, we are not only reflecting the real-world situation that our program
is meant to model, but we are also creating clean and re-usable code. Each class
only knows about what they specifically need to know about, and we create a
single source of truth by keeping our information central in our relationship
model.

## Further Practice

Below you'll find all the code for the `Customer` class, including a few new
methods. Think about expanding on the `Customer` and `Waiter` classes and about
what other methods might be possible using the has-many-through relationship.
For starters, try some of the following:

* A waiter's most frequent customer
* The meal of a waiter's worst tipping customer
* The average tips for the most experienced waiter and the average tips for the
  least experienced waiter

```ruby
class Customer
  attr_accessor :name, :age

  @@all = []

  def initialize(name, age)
    @name = name
    @age = age
    @@all << self
  end

  def self.all
    @@all
  end

  def meals
    Meal.all.select do |meal|
      meal.customer == self
    end
  end

  def waiters
    meals.map do |meal|
      meal.waiter
    end
  end

  def new_meal(waiter, total, tip=0)
    Meal.new(waiter, self, total, tip)
  end

  def new_meal_20_percent(waiter, total)
    tip = total * 0.2
    Meal.new(waiter, self, total, tip)
  end

  def self.oldest_customer
    oldest_age = 0
    oldest_customer = nil
    self.all.each do |customer|
      if customer.age > oldest_age
        oldest_age = customer.age
        oldest_customer = customer
      end
    end
    oldest_customer
  end

end
```

<p class='util--hide'>View <a href='https://learn.co/lessons/ruby-objects-has-many-through-readme'>Has Many Objects Through</a> on Learn.co and start learning to code for free.</p>
