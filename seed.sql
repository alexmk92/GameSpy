-- Test data for gamespy, all data must be input in order to avoid dependence errors
BEGIN

-- Publishers
INSERT INTO publishers VALUES('', 'Activision');
INSERT INTO publishers VALUES('', 'Infinity Ward');
INSERT INTO publishers VALUES('', 'Ubisoft');
INSERT INTO publishers VALUES('', 'Naughty Dog');
INSERT INTO publishers VALUES('', 'Blizzard Entertainment');
INSERT INTO publishers VALUES('', 'EA Games');
INSERT INTO publishers VALUES('', 'Sony Online Entertainment');

-- Manufacturers
INSERT INTO manufacturers VALUES('', 'Nintendo');
INSERT INTO manufacturers VALUES('', 'Sony');
INSERT INTO manufacturers VALUES('', 'Microsoft');
INSERT INTO manufacturers VALUES('', 'Atari');
INSERT INTO manufacturers VALUES('', 'Sega');

-- Game test data
INSERT INTO games VALUES('', 2, 'FPS', 'Call of Duty : Advanced Warfare', SYSDATE, 'The latest COD game', '50.00', 'some tags',0);
INSERT INTO games VALUES('', 1, 'FPS', 'Call of Duty : Modern Warfare 3', '20/JAN/2014', 'Last years COD game', '35.00', 'some tags',0);
INSERT INTO games VALUES('', 6, 'SPORT', 'FIFA 15', SYSDATE, 'The latest FIFA game', '50.00', 'some tags',0);
INSERT INTO games VALUES('', 6, 'SPORT', 'FIFA 12', SYSDATE, '2012 FIFA game', '5.00', 'some tags',0);
INSERT INTO games VALUES('', 5, 'MMO', q'{World of Warcraft : Warlords of Draenor}', SYSDATE, 'The latest expansion content for WoW', '42.50', 'some tags',0);
INSERT INTO games VALUES('', 2, 'MMO', 'EverQuest Next', SYSDATE, 'The latest EverQuest game, a revolution for MMOs', '50.00', 'some tags',0);
INSERT INTO games VALUES('', 2, 'MMO', 'Grand Theft Auto V', SYSDATE, 'The very latest GTA GAME with amazing graphics', '50.00', 'some tags',1);

-- Console test data
INSERT INTO consoles VALUES('', 3, 'XBOX ONE', '03/FEB/2014', '400.00', 'The latest XBOX console', 'some tags',0);
INSERT INTO consoles VALUES('', 3, 'XBOX 360', '03/MAR/2011', '200.00', 'The 3rd gen XBOX 360', 'some tags',0);
INSERT INTO consoles VALUES('', 2, 'Playstation 4', '03/JAN/2014', '360.00', 'The latest Playstation console', 'some tags',0);
INSERT INTO consoles VALUES('', 2, 'PC', '22/AUG/2014', '710.00', 'Our best personal home gaming rig', 'some tags',0);


-- Stores
INSERT INTO stores VALUES('', 'Gamestop', 'A shop on the highstreet', 'PL48AP', null);
INSERT INTO stores VALUES('', 'Game', 'A shop located in Wellingborough', 'NN84PQ', null);
INSERT INTO stores VALUES('', 'PlayMe', 'A new console and game retailer in luton', 'LU25PQ', null);

-- Items
-- COD 6 on the XBOX1 with unset store price at gamestop
INSERT INTO items VALUES('', 1, 1, 1, 'This new game is amazing', null,4);
-- COD 6 on the PS4 with set price at gamestop
INSERT INTO items VALUES('', 1, 1, 3, 'This new game is amazing', '70.00',5);
-- Blank description and price, see if it inherits both
INSERT INTO items VALUES('', 1, 6, 4, null, null,3);

COMMIT;
END;