s = rng("default");
training_sequence_length = 500;
training_sequence = randi([0 1], training_sequence_length,1);
name = "training_sequence.mat";
save(name,"training_sequence");