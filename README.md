Usage
========================

Let's start out by initializing our template:

    require 'erb'
    require 'superb'

    # Create a plain ERB template    
    erb = ERB.new("My friend <%= @name %> is <%= @age %> years old")

    # Create a Superb::Template that is bound to the ERB
    # template.  Initialize the 'name' and 'age' fields.
    t   = Superb::Template.new(erb, name: "Bob", age: 22)

Calling Superb::Template#render without any arguments renders the template based upon its current state:

    t.render
    # Outcome: "My friend Bob is 22 years old"

Templates behave kind of like Javascript objects.  That is, their fields can be reassigned via Hash syntax or via setters:

    t[:name] = "Brian"
    t.age    = 29
    t.render
    # Outcome: "My friend Brian is 29 years old"

You can overwrite several fields at once by invoking Superb::Template#merge! :

    t.merge!(name: "Fred", age: 52)
    t.render
    # Outcome: "My friend Fred is 52 years old" 

Sometimes, you only want to override a template's field temporarily.  This can be achieved by passing a Hash of overrides to the Superb::Template#render method:

    t.render(name: "Bert")
    # Outcome: "My friend Bert is 52 years old" 

    t.render
    # Outcome: "My friend Fred is 52 years old"

Alternatively, you can create a copy of the template and modify the copy:

    t2 = t.dup
    t2.name = "Mike"
    t2.render
    # Outcome: "My friend Mike is 52 years old"
