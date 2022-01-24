local function main()
    math.randomseed(os.time());
    print(math.random());
    local bgGroup = display.newGroup();
    local mainGroup = display.newGroup();
    local uiGroup = display.newGroup();

    local physics = require("physics");
    physics.start();
    physics.setGravity(0,0);

    local invaderBulletSound = audio.loadSound("sounds/InvaderBullet.wav");
    local shipHitSound = audio.loadSound("sounds/ShipHit.wav");
    local shipBulletSound = audio.loadSound("sounds/ShipBullet.wav");
    local invaderHitSound = audio.loadSound("sounds/InvaderHit.wav");

    local playerLivesText = display.newText(uiGroup, "Lives: ", 200, 20, "fonts/unifont.ttf", 20);
    local killsText = display.newText(uiGroup, "Kills: ", 40, 20, "fonts/unifont.ttf", 20);

    local killCount = 0
    local killCountText = display.newText(uiGroup, killCount, 80, 20, "fonts/unifont.ttf", 20);

    local playerDeadText = display.newText(uiGroup, "", display.contentCenterX, 450, "fonts/unifont.ttf", 25);

    local tableOfEnemies = {};

    local player = display.newImageRect(mainGroup,"images/Ship.png",30,15);
    local function playerSetup()
        player.x = display.contentCenterX;
        player.y = 450;
        player.hp = 3;
        player.speed = 100;
        player.canShoot = true;
        player.isAlive = true;
        player.liveIcon1 = display.newImageRect(uiGroup,"images/Ship.png",20,10);
        player.liveIcon1.x = 310
        player.liveIcon1.y = 20
        player.liveIcon2 = display.newImageRect(uiGroup,"images/Ship.png",20,10);
        player.liveIcon2.x = 285
        player.liveIcon2.y = 20
        player.liveIcon3 = display.newImageRect(uiGroup,"images/Ship.png",20,10);
        player.liveIcon3.x = 260
        player.liveIcon3.y = 20
    end
    playerSetup();
    physics.addBody(player,"dynamic",{isSensor=true});
    local function playerMoveLeft(event)
        if event.phase == "down" then 
            player:setLinearVelocity(player.speed*(-1),0)
        else
            player:setLinearVelocity(0,0);
        end
    end
    local function playerMoveRight(event)
        if event.phase == "down" then 
            player:setLinearVelocity(player.speed,0)
        else
            player:setLinearVelocity(0,0);
        end
    end

    local function createEnemies()
        enemiesStartingHeight = 80;
        local function createEnemy(path,x,y,kind,hp,indeks)
            local newEnemy = display.newImageRect(mainGroup,path,30,20);
            newEnemy.x = x;
            newEnemy.y = y;
            newEnemy.kind = kind;
            newEnemy.hp = hp;
            newEnemy.indeks = indeks;
            physics.addBody(newEnemy,"static",{isSensor=true});
            table.insert(tableOfEnemies,newEnemy);
        end
        for i=1,7 do createEnemy("images/InvaderA1.png",i*40,enemiesStartingHeight,"A1",1,i) end
        for i=1,7 do createEnemy("images/InvaderA2.png",i*40,enemiesStartingHeight+30,"A2",1,i+7) end
        for i=1,7 do createEnemy("images/InvaderB1.png",i*40,enemiesStartingHeight+60,"B1",1,i+14) end
        for i=1,7 do createEnemy("images/InvaderB2.png",i*40,enemiesStartingHeight+90,"B2",1,i+21) end
        for i=1,7 do createEnemy("images/InvaderC1.png",i*40,enemiesStartingHeight+120,"C1",1,i+28) end
        for i=1,7 do createEnemy("images/InvaderC2.png",i*40,enemiesStartingHeight+150,"C2",2,i+35) end
    end

    local function moveEnemies()
        local function moveRight()
            for i=1,#tableOfEnemies do
                if tableOfEnemies[i].x ~= nil then
                    tableOfEnemies[i].x = tableOfEnemies[i].x + 5;
                end
            end
        end
        local function moveBottom()
            for i=1,#tableOfEnemies do
                if tableOfEnemies[i].y ~= nil then
                    tableOfEnemies[i].y = tableOfEnemies[i].y + 5;
                end
            end
        end
        local function moveLeft()
            for i=1,#tableOfEnemies do
                if tableOfEnemies[i].x ~= nil then
                    tableOfEnemies[i].x = tableOfEnemies[i].x - 5;
                end
            end
        end
        moveRight();
        timer.performWithDelay(500,moveRight);
        timer.performWithDelay(1000,moveRight);
        timer.performWithDelay(1500,moveBottom);
        timer.performWithDelay(2000,moveBottom);
        timer.performWithDelay(2500,moveBottom);
        timer.performWithDelay(3000,moveLeft);
        timer.performWithDelay(3500,moveLeft);
        timer.performWithDelay(4000,moveLeft);
        timer.performWithDelay(4500,moveLeft);
        timer.performWithDelay(5000,moveLeft);
        timer.performWithDelay(5500,moveLeft);
        timer.performWithDelay(6000,moveLeft);
        timer.performWithDelay(6500,moveLeft);
        timer.performWithDelay(7000,moveBottom);
        timer.performWithDelay(7500,moveBottom);
        timer.performWithDelay(8000,moveBottom);
        timer.performWithDelay(8500,moveRight);
        timer.performWithDelay(9000,moveRight);
        timer.performWithDelay(9500,moveRight);
        timer.performWithDelay(10000,moveRight);
        timer.performWithDelay(10500,moveRight);
    end

    local function createEnemyBullet()
        rnd = math.random(1,#tableOfEnemies);
        if tableOfEnemies[rnd].kind == "A1" or tableOfEnemies[rnd].kind == "B1" or tableOfEnemies[rnd].kind == "C2" then
            audio.play(invaderBulletSound);
            local bullet = display.newImageRect(mainGroup,"images/Bullet.png",2,10);
            physics.addBody(bullet,"dynamic",{isSensor=true});
            bullet.isBullet = true;
            bullet.x = tableOfEnemies[rnd].x;
            bullet.y = tableOfEnemies[rnd].y;
            bullet:setLinearVelocity(0,300);
            local function enemyBulletCollide(self, event)
                if event.other.canShoot ~= nil then
                    local function destroy(event)
                        display.remove(bullet);
                        event.other.hp = event.other.hp - 1;
                        if event.other.hp == 2 then display.remove(event.other.liveIcon1); end
                        if event.other.hp == 1 then display.remove(event.other.liveIcon2); end
                        if event.other.hp <= 0 then
                            local function movePlayerAway()
                                player.y = 99999999999999;
                                playerDeadText.text = "Press Enter to Restart";
                            end
                            timer.performWithDelay(10,movePlayerAway);
                            player.isAlive = false;
                            display.remove(event.other.liveIcon3);
                            audio.play(shipHitSound);
                        end
                    end
                    timer.performWithDelay(10,destroy(event));
                end
            end
            bullet.collision = enemyBulletCollide;
            bullet:addEventListener("collision");
        end
    end

    local function createPlayerBullet()
        player.canShoot = false;
        local function canShootAgain()
            player.canShoot = true;
        end
        timer.performWithDelay(500,canShootAgain);
        audio.play(shipBulletSound);
        local bullet = display.newImageRect(mainGroup,"images/Bullet.png",2,10);
        physics.addBody(bullet,"dynamic",{isSensor=true});
        bullet.isBullet = true;
        bullet.x = player.x;
        bullet.y = player.y - 15;
        bullet:setLinearVelocity(0,-400);
        local function playerBulletCollide(self, event)
            if event.other.kind ~= nil then
                local function destroy(event)
                    display.remove(bullet);
                    event.other.hp = event.other.hp - 1;
                    if event.other.hp <= 0 then
                        for i=1,#tableOfEnemies do
                            if tableOfEnemies[i].indeks == event.other.indeks then
                                table.remove(tableOfEnemies,i);
                                break;
                            end
                        end
                        display.remove(event.other);
                        killCount = killCount + 1;
                        killCountText.text = killCount;
                        audio.play(invaderHitSound);
                        if #tableOfEnemies == 0 then
                            timer.cancelAll();
                            player.canShoot = true;
                            local function resetEnemies()
                                createEnemies();
                                timer.performWithDelay(500,createEnemyBullet,-1);
                                moveEnemies();
                                timer.performWithDelay(11000,moveEnemies,-1);
                            end
                            timer.performWithDelay(20,resetEnemies);
                        end
                    end
                end
                timer.performWithDelay(10,destroy(event));
            end
        end
        bullet.collision = playerBulletCollide;
        bullet:addEventListener("collision");
    end
    local function playerShoot(event)
        if event.phase == "down" and player.canShoot then createPlayerBullet(); end
    end

    local function gameRestart()
        playerDeadText.text = "";
        playerSetup();
        killCount = 0;
        killCountText.text = killCount;
        timer.cancelAll();
        player.canShoot = true;
        player.isAlive = true;
        player.y = 450;
        for i, v in ipairs(tableOfEnemies) do
            display.remove(tableOfEnemies[i]);
            tableOfEnemies[i] = nil;
        end
        createEnemies();
        timer.performWithDelay(500,createEnemyBullet,-1);
        moveEnemies();
        timer.performWithDelay(11000,moveEnemies,-1);    
    end

    local function keyDown(event)
        if event.keyName == "left" and player.isAlive then playerMoveLeft(event);
        elseif event.keyName == "right" and player.isAlive then playerMoveRight(event);
        elseif event.keyName == "space" and player.isAlive then playerShoot(event);
        elseif event.keyName == "enter" and player.isAlive == false then timer.performWithDelay(10,gameRestart);
        else end
    end
    Runtime:addEventListener("key", keyDown);

    createEnemies();
    timer.performWithDelay(500,createEnemyBullet,-1);
    moveEnemies();
    timer.performWithDelay(11000,moveEnemies,-1);
end
timer.performWithDelay(1000,main);
