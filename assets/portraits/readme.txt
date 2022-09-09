Portraits are generated using StableDiffusion, using the following prompt pattern:

"animated portrait of <animal> <description>, cgi, Pixar style, plain <color> background, dramatic lighting, simple"

For example:

python optimizedSD\optimized_txt2img.py --prompt "animated portrait of bobcat, cgi, Pixar style, plain green background, dramatic lighting, simple" --n_iter 5 --n_samples 5 --precision full --sampler plms --W 512 --H 512