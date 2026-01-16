use context starter2024
import image as I
import reactors as R


data Posn:
    ## Area of the game screen = 800 * 500 " range of (x, y) "
  | posn(x, y)
    
end

data World:
    
    ## mutable data in my game world
    
  | world(plane :: Posn, birds :: List<Posn>, score :: Number)
    
end


a-url = "https://opengameart.org/sites/default/files/aircraft.png"
e-url = "https://i.ibb.co/whwZPJcd/eagle-flap.png"

Aircraft = I.image-url(a-url)
eagle = I.image-url(e-url)
sky = I.rectangle(1000, 600, "solid", "lightblue")


fun put-eagles(birds, scene):
  
  doc: " checks the list of positions. if empty returns the scene or recursively calls place-image of the eagle image in the game ( puts the image of the eagle on the sky )"
  
  cases (List) birds:
    | empty => scene ### scene is sky 
    | link(f, r) => 
      
      new_scene = I.place-image(eagle, f.x, f.y, scene)
      put-eagles(r, new_scene)
      
  end
end



fun move-eagles(birds):
  
  doc: "Moves the eagles left by 4 units, removing those off-screen. Returns updated list of positions if condition b.x < -40  not satisfied."
  
  cases (List) birds:
    | empty => empty  
    | link(f, r) =>
        ask:
        | f.x < -40 then: move-eagles(r)
        | otherwise: link(posn(f.x - 4, f.y), move-eagles(r))
        end
  end
end



fun add-eagles(birds):
  
  doc: "using num-random algorithm we make a very less probabilty so that the game is on easy mode(eagles aren't many). we use num-random again for moving the random eagle on y-axis"
  
  ask:
    | num-random(100) < 6 then: link(posn(1050, num-random(600)), birds)
      
    | otherwise: birds  
  end
end




fun tick_handler(w):
  
  doc:"handles the calculations of all the events "
  
  cases (World) w:
      
    | world(plane, birds, score) =>
      
      new_birds = add-eagles(move-eagles(birds)) 
      
      # adds new moving eagles and count the score based on the time survived. 
      
        world(plane, new_birds, score + 1)
  end
end




fun key_handler(w, k):
  
  doc: "Handles user input for plane movement.( 'Up' , 'down') and ('Left', 'right') keys move the plane vertically and horizontally, it also wraps around both waysso that the plane is visible and returns the updated world with the plane in its new position."
  
  #### efficiently moves and wraps the plane
  
  ask:
    | k == "up" then:
      new_y = num-modulo(w.plane.y - 20, 600)  
      
        world(posn(w.plane.x, new_y), w.birds, w.score)
      
    | k == "down" then:
      new_y = num-modulo(w.plane.y + 20, 600)  
      
        world(posn(w.plane.x, new_y), w.birds, w.score)
      
    | k == "left" then:
      new_x = num-modulo(w.plane.x - 20, 1000)  
      
        world(posn(new_x, w.plane.y), w.birds, w.score)
      
    | k == "right" then:
      new_x = num-modulo(w.plane.x + 20, 1000) 
      
        world(posn(new_x, w.plane.y), w.birds, w.score)
      
    | otherwise: w
      
  end
end


fun draw_everything(w):
  
  doc: "If crash(w) returns true, overlays a GAME OVER image on the screen with the image of final score above in 'red'. Otherwise, draws the sky, then eagles, then plane, and shows the current score at the top in 'black'."
  
  if crashed(w):
    s1 = sky
    
    ## Updating the score in the text image 
    
    score_txt = I.text("Score: " + num-to-string(w.score), 18, "red") 
    
    ## I.text("string text", 'font size', 'color')
    
    s2 = I.place-image(score_txt, 50, 30, s1) 
    
    game_over_img = I.text("GAME OVER !!", 58, "red")
   
    I.place-image(game_over_img, 500, 300, s2) ## Centre of the game screen
    
  else:
    
    s1 = sky 
    
    s2 = put-eagles(w.birds, s1)
    
    s3 = I.place-image(Aircraft, w.plane.x, w.plane.y, s2)
    
    score_txt = I.text("Score: " + num-to-string(w.score), 18, "black")
    
    I.place-image(score_txt, 50, 30, s3)
    
  end
end



fun crashed(w):
  
  doc:" checks the distance between the coordinates of plane and eagle (checks if d < 50 pixels with f or checks with the rest of the birds) returns a boolean value "
  
  ## helper function
fun check_crash(plane, birds):
    
    
  cases (List) birds:
    | empty => false
      | link(f, r) =>
        
        d = num-sqrt(((plane.x - f.x) * (plane.x - f.x)) + ((plane.y - f.y) * (plane.y - f.y)))      
        
        #### distance formula (logic for crash in this case)
        
        if d < 40:
          true
        else:
          check_crash(plane, r)
       end
    end
 end
  
  check_crash(w.plane, w.birds)
  
end


my_game = reactor:
  
  init: world(posn(150, 250), empty, 0),
  on-tick: tick_handler,
  on-key: key_handler,
  to-draw: draw_everything,
  stop-when: crashed
    
end

R.interact(my_game)

fun my-Foldl(lst, acc, combine):
  cases (List) lst:
    |empty => acc
    |link(f,rest) =>
      my-Foldl(rest, combine(acc, f), combine)
  end
end

numbers = [list: 1, 2, 3, 4, 5]
