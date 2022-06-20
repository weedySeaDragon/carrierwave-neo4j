## CarrierWave for ActiveGraph

This gem adds support for Neo4j 3.0+ (neo4j.rb 9.6.0+) to CarrierWave 2.1.0+, see the CarrierWave documentation for more detailed usage instructions.

### Installation Instructions

Add to your Gemfile:

```ruby
gem 'carrierwave-neo4j', '~> 3.0', require: 'carrierwave/active_graph'
```

You can see example usage in `spec/active_graph_realistic_spec.rb` but in brief, you can use it like this:

```ruby
class AttachmentUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end

class Asset
  include ActiveGraph::Node

  property :attachment, type: String
  mount_uploader :attachment, AttachmentUploader
end
```

If you want image manipulation, you will need to install ImageMagick

On Ubuntu:

```sh
sudo apt-get install imagemagick --fix-missing
```

On macOS:

```sh
brew install imagemagick
```

### Development

```sh
bundle install


rake neo4j:install[community-4.0.11,test] # this no longer works

#  Go to https://neo4j.com/download/  to download the latest version of Neo4j. 
#  Extract it into  the local [project directory]/db/neo4j/[environment]
#   ex: [project directory]/db/neo4j/test

# Ensure that your NEO4J_HOME points to  [project directory]/db/neo4j/[environment] that you're using
echo $NEO4J_HOME # or whatever command works on your OS

# Ensure that you are running a version of java that is compatible with neo4j
java --version

# If you need to use a different version, ensure that JAVA_HOME is pointing to the correct java directory
echo $JAVA_HOME # or whatever command works on your os

rake neo4j:start[test]
rake spec
```

### Troubleshooting

#### Neo4j says it starts, but doesn't
* Double-check your NEO4J_HOME directory and ensure it's the right one. This is important if you have Neoj Desktop installed.
* Ensure your version of java is correct
* You may see more debugging output if you try to start a console with the verbose flag:   `neo4j console --verbose`.  If you see a lot of java error messages, it may be that you're using a version of java that is not compatible with Neo4j.
* Check to see if another instance of neo4j is running by looking at the TCP connections

  `   lsof -wni tcp  # macOS`
    
  You should not see any other `neo4j`- related programs or processes .  If you do, track them down and stop those programs/processes.




#### Files are nil

If you aren't getting your files back after querying a record from Neo4j, be aware that this will only happen automatically for the `Model#find` method. For all other finders (`#all`, `#first`, `#find_by`, `#find_by_*`, `#find_by_*!`, `#last`) you will need to force a reload so the model sees the file. For example:

```ruby
users = User.all
users.each(&:reload_from_database!)
```

Sorry, this sucks. But this is a limitation of Neo4j.rb as these other finders don't fire any callbacks.

#### binstubs (particularly `bin/rspec`) seem broken

If you're getting some infinite recursion when you run the specs that ultimately results in an error like:

```
`ensure in require': CRITICAL: RUBYGEMS_ACTIVATION_MONITOR.owned?: before false -> after true (RuntimeError)
```

You may want to try:

```sh
rm .bundle/config
bundle install
```
