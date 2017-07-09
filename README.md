# BFGParams

BFGParams is a small serialization / deserialization helper class written in Objective-C. It is intended for converting back and forth between first-class objects and JSON, but can also parameterize a first-class object into a URL query. It's primary benefit is its small size. A package like [RestKit](https://github.com/RestKit/RestKit) may provide a more complete solution.

## Usage

Copy the six files from the `source` directory into your project.

## More Info

BFGParams provides objectification of many but NOT ALL possible JSON constructs. Notably, because sub-classes of bfgParams need explicit typing hints in their declarations, there are limitations as to where they can be placed in collections. Notably, they cannot be placed in dictionaries nor in Arrays of Arrays (but they can be placed in top level arrays that are named using the sub-classing note convention above). Not being allowed in generic dictionaries should not be a major limitation since sub-classes are effectively dictionary wrappers so rather than using a dictionary, use a sub-class of bfgParams.

See the unit-tests for examples.

## Note

The unit tests made available in this project exist only to show its basic usage. As time permits I (or others) may add in some actual unit tests.
