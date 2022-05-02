### A Pluto.jl notebook ###
# v0.19.2

using Markdown
using InteractiveUtils

# ╔═╡ 5b2ee40e-a2b8-11ea-0fef-c35fe6918860
md"""
# The tower of Hanoi

The tower of hanoi is a famous puzzle.

![setup of the tower of a hanoi](https://upload.wikimedia.org/wikipedia/commons/0/07/Tower_of_Hanoi.jpeg)

The game consists of three rods with disks stacked on top of them. The puzzle will start with all disks in a stack on one of the rods (like in the picture). The goal is to move all the discs to a single stack on the last rod.

To move the disks, you have to follow the following rules:

* You can move only one disk at a time.
* For each move, you have to take the upper disk from one of the stacks, and place it on top of another stack or empty rod.
* You cannot place a larger disk on top of a smaller disk.

This notebook will define a Julia implementation of the puzzle. It's up to you to write an algorithm that solves it.
"""

# ╔═╡ 95fbd0d2-a2b9-11ea-0682-fdf783251797
md"""
## Setting up the game pieces

What does a Julia implementation look like? We're not really interested in writing code that will manipulate physical disks. Our final goal is a function that will give us a _recipe_ to solve the tower of hanoi, which is just a list of moves to make. Because of that, we can use a lot of abstraction in our implementation, and keep the data structures as simple as possible.

To start, we have to define some representation of the disks and the stacks. The disks have one important property, which is that they are ordered. We can use integers to represent them.
"""

# ╔═╡ 620d6834-a2ba-11ea-150a-2132bb54e4b3
num_disks = 8

# ╔═╡ 35ada214-a32c-11ea-0da3-d5d494b28467
md"""(Side note: the number of disks is arbitrary. When testing your function, you may want to set it to 1 or 2 to start.)"""

# ╔═╡ 7243cc8e-a2ba-11ea-3f29-99356f0cdcf4
all_disks = 1:num_disks

# ╔═╡ 7e1ba2ac-a2ba-11ea-0134-2f61ed75be18
md"""
A single stack can be represented as an array with all the disks in it. We will list them from top to bottom.
"""

# ╔═╡ 43781a52-a339-11ea-3803-e56e2d08aa83
first_stack = collect(all_disks)

# ╔═╡ b648ab70-a2ba-11ea-2dcc-55b630e44325
md"""
Now we have to make three of those. 
"""

# ╔═╡ 32f26f80-a2bb-11ea-0f2a-3fc631ada63d
starting_stacks = [first_stack, [], []]

# ╔═╡ e347f1de-a2bb-11ea-06e7-87cca6f2a240
md"""
## Defining the rules

Now that we have our "game board", we can implement the rules.

To start, we make two functions for states. A state of the game is just an array of stacks.

We will define a function that checks if a state is okay according to the rules. To be legal, all the stacks should be in the correct order, so no larger disks on top of smaller disks. 

Another good thing to check: no disks should have appeared or disappeared since we started!
"""

# ╔═╡ 512fa6d2-a2bd-11ea-3dbe-b935b536967b
function islegal(stacks)
	order_correct = all(issorted, stacks)
	
	#check if we use the same disk set that we started with
	
	disks_in_state = sort([disk for stack ∈ stacks for disk ∈ stack])
	disks_complete = disks_in_state == all_disks
	
	order_correct && disks_complete
end

# ╔═╡ c56a5858-a2bd-11ea-1d96-77eaf5e74925
md"""
Another function for states: check if we are done! We can assume that we already checked if the state was legal. So we know that all the disks are there and they are ordered correctly.  To check if we are finished, we just need to check if the last stack contains all the disks.
"""

# ╔═╡ d5cc41e8-a2bd-11ea-39c7-b7df8de6ae3e
function iscomplete(stacks)
	last(stacks) == all_disks
end

# ╔═╡ 53374f0e-a2c0-11ea-0c91-97474780721e
md"""
Now the only rules left to implement are the rules for moving disks. 

We could implement this as another check on states, but it's easier to just write a legal `move` function. Your solution will specify moves for the `move` function, so this will be the only way that the stacks are actually manipulated. That way, we are sure that nothing fishy is happening.

We will make our `move` function so that its input consists of a state of the game, and instructions for what to do. Its output will be the new state of the game.

So what should those instructions look like? It may seem intuitive to give a _disk_ that should be moved, but that's more than we need. After all, we are only allowed to take the top disk from one stack, and move it to the top of another. So we only have to say which _stacks_ we are moving between.

(Note that the `move` function is okay with moving a larger disk on top of a smaller disk. We already implemented that restriction in `islegal`.)
"""

# ╔═╡ e915394e-a2c0-11ea-0cd9-1df6fd3c7adf
function move(stacks, source::Int, target::Int)
	#check if the from stack if not empty
	if isempty(stacks[source])
		error("Error: attempted to move disk from empty stack")
	end
	
	new_stacks = deepcopy(stacks)
	
	disk = popfirst!(new_stacks[source]) #take disk
	pushfirst!(new_stacks[target], disk) #put on new stack
	
	return new_stacks
end

# ╔═╡ 87b2d164-a2c4-11ea-3095-916628943879
md"""
## Solving the problem

We have implemented the game pieces and the rules, so you can start working on your solution.

To do this, you can fill in the `solve(stacks)` function. This function should give a solution for the given `stacks`, by moving all the disks from stack 1 to stack 3.

As output, `solve` should give a recipe, that tells us what to do. This recipe should be an array of moves. Each moves is a `(source, target)` tuple, specifying from which stack to which stack you should move.

For example, it might look like this:
"""

# ╔═╡ 29b410cc-a329-11ea-202a-795b31ce5ad5
function wrong_solution(stacks)::Array{Tuple{Int, Int}}
	return [(1,2), (2,3), (2,1), (1,3)]
end

# ╔═╡ ea24e778-a32e-11ea-3f11-dbe9d36b1011
md"""
Now you can work on building an actual solution. Some tips:
* `solve(stacks)` can keep track of the board if you want, but it doesn't have to.
* The section below will actually run your moves, which is very useful for checking them.
* If you want, you can change `num_disks` to 1 or 2. That can be a good starting point.
"""

# ╔═╡ 3eb3c4c0-a2c5-11ea-0bcc-c9b52094f660
md"""
## Checking solutions

This is where we can check a solution. We start with a function that takes our recipe and runs it.
"""

# ╔═╡ e8c5b407-4542-4fa9-a019-0e149693e032
begin
	start = [[],[],[]]
	append!(start[2],collect(all_disks))
end

# ╔═╡ 11e8b47a-42c2-4afe-9f36-2f58c3a6f69e
start

# ╔═╡ 4709db36-a327-11ea-13a3-bbfb18da84ce
function run_solution(solver::Function, start = starting_stacks)
	moves = solver(deepcopy(start)) #apply the solver
	
	all_states = Array{Any,1}(undef, length(moves) + 1)
	all_states[1] = start
	
	for (i, m) ∈ enumerate(moves)
		try
			all_states[i + 1] = move(all_states[i], m[1], m[2])
		catch
			all_states[i + 1] = missing
		end
	end
	
	return all_states
end

# ╔═╡ dd62a30e-698c-463b-94fe-ae244435df1b
function run_solution_adv(solver::Function, moo::Tuple{Int,Int})

	if moo[1] - moo[2] == 0 || moo[1] ∉ [1,2,3] || moo[2] ∉ [1,2,3]
		return []
	else
		
		start = [[],[],[]]
		append!(start[moo[1]],collect(all_disks))
		moves = solver(moo) #apply the solver
		
		all_states = Array{Any,1}(undef, length(moves) + 1)
		all_states[1] = start
		
		for (i, m) ∈ enumerate(moves)
			try
				all_states[i + 1] = move(all_states[i], m[1], m[2])
			catch
				all_states[i + 1] = missing
			end
		end
	end
	
	return all_states
end

# ╔═╡ 372824b4-a330-11ea-2f26-7b9a1ad018f1
md"""
You can use this function to see what your solution does.

If `run_solution` tries to make an impossible move, it will give `missing` from that point onwards. Look at what happens in the `wrong_solution` version and compare it to the moves in `wrong_solution`.
"""

# ╔═╡ d2227b40-a329-11ea-105c-b585d5fcf970
run_solution(wrong_solution)

# ╔═╡ bb5088ec-a330-11ea-2c41-6b8b92724b3b
md"""
Now that we have way to run a recipe, we can check if its output is correct. We will check if all the intermediate states are legal and the final state is the finished puzzle.
"""

# ╔═╡ 10fb1c56-a2c5-11ea-2a06-0d8c36bfa138
function check_solution(solver::Function, start = starting_stacks)
	try
		#run the solution
		all_states = run_solution(solver, start)
		
		#check if each state is legal
		all_legal = all(islegal, all_states)
		
		#check if the final state is is the completed puzzle
		complete = (iscomplete ∘ last)(all_states)
		
		all_legal && complete
	catch
		#return false if we encountered an error
		return false
	end
end

# ╔═╡ ad753a0f-5174-4caa-b16f-a12b7dbf4890
function check_solution_adv(solver::Function, moo::Tuple{Int,Int})

	if moo[1] - moo[2] == 0 || moo[1] ∉ [1,2,3] || moo[2] ∉ [1,2,3]
		return true
	else
		last = [[],[],[]]
		append!(last[moo[2]],collect(all_disks))
		all_states = run_solution_adv(solver,moo)
		
		try
			#run the solution
			all_states = run_solution_adv(solver,moo)
			
			#check if each state is legal
			all_legal = all(islegal, all_states)
			
			#check if the final state is is the completed puzzle
			last_state = all_states[lastindex(all_states)]
			complete = last_state == last
			
			all_legal && complete
		catch
			#return false if we encountered an error
			return false
		end
	end
end

# ╔═╡ 2fae59d1-45d9-4b9c-a45b-7ec8a6f5ab81
md"""## Important Functions"""

# ╔═╡ 614cb8fe-3fca-4b04-ae9f-5004fa835e2e
swap_two!(n::Number, x::Number, y::Number) = n == x ? y : (n == y ? x : n)

# ╔═╡ 33d7c46e-3e27-482b-a1f1-bf43e4d3b054
swap_two!(ra::AbstractArray{<:Number}, args...) = ra .= swap_two!.(ra, args...)

# ╔═╡ caa7a01a-acf6-49e7-85b5-217693313cb3
swap_two!(ra::AbstractArray{<:AbstractArray},args...) = swap_two!.(ra,args...)

# ╔═╡ 83e7294b-6ceb-449b-845d-7c975b15e55b
numref(ra) = [x isa Number ? Ref(ra, i) : x for (i, x) ∈ enumerate(ra)]

# ╔═╡ 9d22986f-d3da-4f7d-9fb4-d1e9acb22a18
swap_two!(n::Base.RefArray, args...) = n[] = swap_two!(n[], args...)

# ╔═╡ ae5f7e5e-30d8-4bd6-927f-ef3ca14e613e
swap_two!(ra::AbstractArray, args...) = swap_two!.(numref(ra), args...)

# ╔═╡ 771ba1cb-4f62-4cdd-a7a5-b6be68d874e0
swap_two(x, args...) = (y = deepcopy(x); swap_two!(y, args...); y)

# ╔═╡ dd674c5e-5f1b-44f8-bb7a-7cdf0c497b45
swap_two(ra::Tuple, args...) = (out = collect(ra); swap_two!(out, args...); (out...,))

# ╔═╡ 5d5abf06-8f25-4a43-8a8a-a7c4fbd7a67f
function no_jump(disks::Int,direction::Bool)::Array{Array}	
	
	moves = []
	#what to do?
	if direction == true
		for i ∈ 1:disks
				if i == 1
					moves = [[1,2],[2,3]]
				else
					n = swap_two(moves,1,3)
					o = deepcopy(moves)
					append!(moves,[[1,2]],n,[[2,3]],o)
				end
		end
	else
		for i ∈ 1:disks
			if i == 1
				moves = [[3,2],[2,1]]
			else
				n = swap_two(moves,1,3)
				o = deepcopy(moves)
				append!(moves,[[3,2]],n,[[2,1]],o)
			end
		end
	end
			
	#[(1,2),(2,3)]		
	#[(1,2),(2,3),(1,2),(3,2),(2,1),(2,3),(1,2),(2,3)]
	
	return moves
end

# ╔═╡ 0c8fe6ea-c6f0-4b6e-b6a6-6bb7dcf1d831
function array2tuple(a::Array)
   (a...,)
end

# ╔═╡ d08905fe-b1f4-471c-ad7a-57073e296f27
function solve(start = starting_stacks)::Array{Tuple{Int, Int}}	

	
	moves = []
	#what to do?

	for i ∈ 1:num_disks
			if i == 1
				moves = [[1,3]]
			else
				n = swap_two(moves,2,3)
				o = swap_two(moves,1,2)
				moves = n
				append!(moves,[[1,3]],o)
			end
	end

	empty = [(1,3)]
	for i ∈ 1:length(moves)
		append!(empty,[array2tuple(moves[i])])
	end
	popfirst!(empty)
		
	return empty
end

# ╔═╡ 7ee5cf0b-fc0e-46cb-9755-e74f25d61213
solve()

# ╔═╡ 9173b174-a327-11ea-3a69-9f7525f2e7b4
run_solution(solve)

# ╔═╡ 8ea7f944-a329-11ea-22cc-4dbd11ec0610
check_solution(solve)

# ╔═╡ 010dbdbc-a2c5-11ea-34c3-837eae17416f
#Don't have to go from 1 to 3 always
function solving(moo::Tuple{Int,Int},start = starting_stacks)::Array{Tuple{Int, Int}}	

	
	if moo[1] - moo[2] == 0 || moo[1] ∉ [1,2,3] || moo[2] ∉ [1,2,3]
		return []
	else
		
		moves = []
		#what to do?
	
		if moo[1] != 1 && moo[2] != 1
			blank = 1
		elseif moo[1] != 2 && moo[2] != 2
			blank = 2
		else
			blank = 3
		end
		
		for i ∈ 1:num_disks
				if i == 1
					moves = [[moo[1],moo[2]]]
				else
					n = swap_two(moves,blank,moo[2])
					o = swap_two(moves,moo[1],blank)
					moves = n
					append!(moves,[[moo[1],moo[2]]],o)
				end
		end
	
		empty = [(moo[1],moo[2])]
		for i ∈ 1:length(moves)
			append!(empty,[array2tuple(moves[i])])
		end
		popfirst!(empty)
				
		#[(1,3)]		
		#[(1,2),(1,3),(2,3)]
		#[(1,3),(1,2),(3,2),(1,3),(2,1),(2,3),(1,3)]
		
		return empty
	end
end

# ╔═╡ 1f844757-f646-46af-8f08-240d21442d5d
solving((2,1))

# ╔═╡ 049f857a-706c-4ffa-b69d-337f08e74083
run_solution_adv(solving,(1,2))

# ╔═╡ 216bc686-db43-4b53-8fc9-8644acf9d2b0
check_solution_adv(solving,(1,2))

# ╔═╡ f2006490-fbd4-4474-809f-74ee66b5bc27
function no_jump_solve(start = starting_stacks)::Array{Tuple{Int, Int}}	
	
	moves = []
	#what to do?
	
	for i ∈ 1:num_disks
			if i == 1
				moves = [[1,2],[2,3]]
			else
				n = swap_two(moves,1,3)
				o = deepcopy(moves)
				append!(moves,[[1,2]],n,[[2,3]],o)
			end
	end

	empty = [(1,2)]
	for i ∈ 1:length(moves)
		append!(empty,[array2tuple(moves[i])])
	end
	popfirst!(empty)
			
	#[(1,2),(2,3)]		
	#[(1,2),(2,3),(1,2),(3,2),(2,1),(2,3),(1,2),(2,3)]
	
	return empty
end

# ╔═╡ 2a9f565e-18bb-4153-b1d3-2816454950a4
no_jump_solve()

# ╔═╡ 4ba3ff77-f364-47d3-88e2-a83920014fb7
run_solution(no_jump_solve)

# ╔═╡ 4558a0f5-b365-48c4-a05e-c1c975c91b4a
check_solution(no_jump_solve)

# ╔═╡ e54add0a-a330-11ea-2eeb-1d42f552ba38
if check_solution(solve) && check_solution(no_jump_solve)
	if num_disks >= 8
		md"""
		#### Congratulations, your solution works! 😎
		"""
	else
		md"""
		Your solution works for $(num_disks) disks. Change `num_disks` to see if it works for 8 or more.
		"""
	end
else
	md"""
	The `solve` function doesn't work yet. Keep working on it!
	"""
end

# ╔═╡ 25f6da02-6f56-4da4-8b3f-44f9620a47c6
#Don't have to go from 1 to 3 always
function no_jump_solving(moo::Tuple{Int,Int},start = starting_stacks)::Array{Tuple{Int, Int}}	

	if moo[1] - moo[2] == 0 || moo[1] ∉ [1,2,3] || moo[2] ∉ [1,2,3]
		return nothing
	else
		moves = []
		#what to do?
	
		if moo[1] != 1 && moo[2] != 1
			blank = 1
		elseif moo[1] != 2 && moo[2] != 2
			blank = 2
		else
			blank = 3
		end
		
		if abs(moo[1]-moo[2]) == 2
			for i ∈ 1:num_disks
					if i == 1
						moves = [[moo[1],blank],[blank,moo[2]]]
					else
						n = swap_two(moves,moo[1],moo[2])
						o = deepcopy(moves)
						append!(moves,[[moo[1],blank]],n,[[blank,moo[2]]],o)
					end
			end
		elseif moo[1] == 2
			for i ∈ 1:num_disks
				if i == 1
					moves = [[moo[1],moo[2]]]
				else
					n = swap_two(moves,blank,moo[2])
					moves = n
					if moo[2] > moo[1]
						append!(moves,[[moo[1],moo[2]]],no_jump(i-1,true))
					else
						append!(moves,[[moo[1],moo[2]]],no_jump(i-1,false))
					end
				end
			end
		elseif moo[2] == 2
			for i ∈ 1:num_disks
				if i == 1
					moves = [[moo[1],moo[2]]]
				else
					n = swap_two(moves,blank,moo[1])
					if moo[2] > moo[1]
						moves = no_jump(i-1,true)
						append!(moves,[[moo[1],moo[2]]],n)
					else
						moves = no_jump(i-1,false)
						append!(moves,[[moo[1],moo[2]]],n)
					end
				end
			end					
		end
							

		
		empty = [(1,2)]
		for i ∈ 1:length(moves)
			append!(empty,[array2tuple(moves[i])])
		end
		popfirst!(empty)
				
		#[(1,2),(2,3)]		
		#[(1,2),(2,3),(1,2),(3,2),(2,1),(2,3),(1,2),(2,3)]
	
		#or
	
		#[(2,3)]
		#[(2,1),(2,3),(1,2),(1,3)]
		#[(2,3),(2,1),(3,2),(2,1),(2,3),(1,2),(2,3),(1,2),(3,2),(2,1),(2,3),(1,2),(2,3)]

		#or

		#[(1,2)]
		#[(1,2),(2,3),(1,2),(3,2)]
		#[(1,2),(2,3),(1,2),(3,2),(2,1),(2,3),(1,2),(2,3),(1,2),(3,2),(2,1),(3,2),(1,2)]
		
		return empty
	end
end

# ╔═╡ b1be2223-1b27-447b-ad70-d747b2e2e0cf
no_jump_solving((3,2))

# ╔═╡ d0932f67-05cb-4cb6-b08f-91dc8e832245
run_solution_adv(no_jump_solving,(3,1))

# ╔═╡ 74822fd2-777f-499c-abce-a358d9fbd65b
check_solution_adv(no_jump_solving,(3,1))

# ╔═╡ 7384ddd3-6b97-4546-8746-3f6a0ea81297
begin
	permutations = [(1,1),(1,2),(1,3),(2,1),(2,2),(2,3),(3,1),(3,2),(3,3)]
	correct = []
	
	for i ∈ permutations
		if check_solution_adv(solving,i) == true && check_solution_adv(no_jump_solving,i) == true
			append!(correct,1)
		end
	end
		
	if length(correct) == length(permutations) 
		if num_disks >= 8
			md"""
			#### Congratulations, your superduper solution works! 😎
			"""
		else
			md"""
			Your superduper solution works for $(num_disks) disks. Change `num_disks` to see if it works for 8 or more.
			"""
		end
	
	else
		md"""
		The `advanced solve` function doesn't work yet. Keep working on it!
		"""
	end
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.2"
manifest_format = "2.0"

[deps]
"""

# ╔═╡ Cell order:
# ╟─5b2ee40e-a2b8-11ea-0fef-c35fe6918860
# ╟─95fbd0d2-a2b9-11ea-0682-fdf783251797
# ╠═620d6834-a2ba-11ea-150a-2132bb54e4b3
# ╟─35ada214-a32c-11ea-0da3-d5d494b28467
# ╠═7243cc8e-a2ba-11ea-3f29-99356f0cdcf4
# ╟─7e1ba2ac-a2ba-11ea-0134-2f61ed75be18
# ╠═43781a52-a339-11ea-3803-e56e2d08aa83
# ╟─b648ab70-a2ba-11ea-2dcc-55b630e44325
# ╠═32f26f80-a2bb-11ea-0f2a-3fc631ada63d
# ╟─e347f1de-a2bb-11ea-06e7-87cca6f2a240
# ╠═512fa6d2-a2bd-11ea-3dbe-b935b536967b
# ╟─c56a5858-a2bd-11ea-1d96-77eaf5e74925
# ╠═d5cc41e8-a2bd-11ea-39c7-b7df8de6ae3e
# ╟─53374f0e-a2c0-11ea-0c91-97474780721e
# ╠═e915394e-a2c0-11ea-0cd9-1df6fd3c7adf
# ╟─87b2d164-a2c4-11ea-3095-916628943879
# ╠═29b410cc-a329-11ea-202a-795b31ce5ad5
# ╟─ea24e778-a32e-11ea-3f11-dbe9d36b1011
# ╠═7ee5cf0b-fc0e-46cb-9755-e74f25d61213
# ╠═d08905fe-b1f4-471c-ad7a-57073e296f27
# ╠═1f844757-f646-46af-8f08-240d21442d5d
# ╠═010dbdbc-a2c5-11ea-34c3-837eae17416f
# ╠═2a9f565e-18bb-4153-b1d3-2816454950a4
# ╠═f2006490-fbd4-4474-809f-74ee66b5bc27
# ╠═b1be2223-1b27-447b-ad70-d747b2e2e0cf
# ╠═25f6da02-6f56-4da4-8b3f-44f9620a47c6
# ╠═5d5abf06-8f25-4a43-8a8a-a7c4fbd7a67f
# ╟─3eb3c4c0-a2c5-11ea-0bcc-c9b52094f660
# ╠═e8c5b407-4542-4fa9-a019-0e149693e032
# ╠═11e8b47a-42c2-4afe-9f36-2f58c3a6f69e
# ╠═4709db36-a327-11ea-13a3-bbfb18da84ce
# ╠═dd62a30e-698c-463b-94fe-ae244435df1b
# ╟─372824b4-a330-11ea-2f26-7b9a1ad018f1
# ╠═d2227b40-a329-11ea-105c-b585d5fcf970
# ╠═9173b174-a327-11ea-3a69-9f7525f2e7b4
# ╠═4ba3ff77-f364-47d3-88e2-a83920014fb7
# ╠═049f857a-706c-4ffa-b69d-337f08e74083
# ╠═d0932f67-05cb-4cb6-b08f-91dc8e832245
# ╟─bb5088ec-a330-11ea-2c41-6b8b92724b3b
# ╠═10fb1c56-a2c5-11ea-2a06-0d8c36bfa138
# ╠═ad753a0f-5174-4caa-b16f-a12b7dbf4890
# ╠═8ea7f944-a329-11ea-22cc-4dbd11ec0610
# ╠═4558a0f5-b365-48c4-a05e-c1c975c91b4a
# ╠═216bc686-db43-4b53-8fc9-8644acf9d2b0
# ╠═74822fd2-777f-499c-abce-a358d9fbd65b
# ╠═e54add0a-a330-11ea-2eeb-1d42f552ba38
# ╠═7384ddd3-6b97-4546-8746-3f6a0ea81297
# ╟─2fae59d1-45d9-4b9c-a45b-7ec8a6f5ab81
# ╠═614cb8fe-3fca-4b04-ae9f-5004fa835e2e
# ╠═33d7c46e-3e27-482b-a1f1-bf43e4d3b054
# ╠═caa7a01a-acf6-49e7-85b5-217693313cb3
# ╠═83e7294b-6ceb-449b-845d-7c975b15e55b
# ╠═9d22986f-d3da-4f7d-9fb4-d1e9acb22a18
# ╠═ae5f7e5e-30d8-4bd6-927f-ef3ca14e613e
# ╠═771ba1cb-4f62-4cdd-a7a5-b6be68d874e0
# ╠═dd674c5e-5f1b-44f8-bb7a-7cdf0c497b45
# ╠═0c8fe6ea-c6f0-4b6e-b6a6-6bb7dcf1d831
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
