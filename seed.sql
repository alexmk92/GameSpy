-- Test data for gamespy, all data must be input in order to avoid dependence errors

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
INSERT INTO games VALUES('', '2', 'FPS', 'Call of Duty : Advanced Warfare', SYSDATE, 'The latest COD game', '50.00', 'some tags');
INSERT INTO games VALUES('', '1', 'FPS', 'Call of Duty : Modern Warfare 3', '20/04/2014', 'Last years COD game', '35.00', 'some tags');
INSERT INTO games VALUES('', '6', 'SPORT', 'FIFA 15', SYSDATE, 'The latest FIFA game', '50.00', 'some tags');
INSERT INTO games VALUES('', '6', 'SPORT', 'FIFA 12', SYSDATE, '2012 FIFA game', '5.00', 'some tags');
INSERT INTO games VALUES('', '5', 'MMO', 'World of Warcraft : Warlords of Draenor', SYSDATE, 'The latest expansion content for WoW', '42.50', 'some tags');
INSERT INTO games VALUES('', '2', 'MMO', 'EverQuest Next', SYSDATE, 'The latest EverQuest game, a revolution for MMOs', '50.00', 'some tags');

-- Console test data

-- Stores
INSERT INTO stores VALUES('', 'Gamestop', 'A shop on the highstreet', 'PL48AP');
INSERT INTO stores VALUES('', 'Game', 'A shop located in Wellingborough', 'NN84PQ');
INSERT INTO stores VALUES('', 'PlayMe', 'A new console and game retailer in luton', 'LU25PQ');

