<?php

namespace Ytake\Gardening;

use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;
use Ytake\Gardening\Foundation\Command;
use Ytake\Gardening\Foundation\Filer;

/**
 * Class SetUpCommand
 */
class SetUpCommand extends Command
{
    /** @var string  command name */
    protected $command = 'gardening:setup';

    /** @var string  command description */
    protected $description = 'Vagrantfile setup';

    /** @var Filer */
    protected $file;

    /** @var string */
    private $name = 'gardening';

    /** @var string */
    protected $current;

    /** @var string */
    protected $projectName;

    /** @var string */
    protected $defaultName;

    /**
     * SetUpCommand constructor.
     *
     * @param Filer $file
     * @param null  $name
     */
    public function __construct(Filer $file, $name = null)
    {
        parent::__construct($name = null);
        $this->file = $file;
        $this->current = getcwd();
        $this->projectName = basename($this->current);
        $this->defaultName = strtolower(trim(preg_replace('/[^A-Za-z0-9-]+/', '-', $this->projectName)));
    }

    /**
     * setup arguments and options
     *
     * @return void
     */
    protected function arguments()
    {
        $this
            ->addOption('filetype', null, InputOption::VALUE_REQUIRED, 'choose configure file type[json or yaml]',
                'yaml')
            ->addOption('name', null, InputOption::VALUE_OPTIONAL, 'The name of the virtual machine.')
            ->addOption('hostname', null, InputOption::VALUE_OPTIONAL, 'The hostname of the virtual machine.',
                $this->name)
            ->addOption('ip', null, InputOption::VALUE_REQUIRED, 'The IP address of the virtual machine.',
                '192.168.10.10')
            ->addOption('aliases', null, InputOption::VALUE_NONE, 'if the aliases file is created.');
    }

    /**
     * @param InputInterface  $input
     * @param OutputInterface $output
     */
    protected function action(InputInterface $input, OutputInterface $output)
    {
        if (!$this->file->exists($this->current . '/Vagrantfile')) {
            $this->file->copy(__DIR__ . '/stub/Vagrantfile.dist', $this->current . '/Vagrantfile');
        }

        if (!$this->file->exists($this->current . '/append.sh')) {
            $this->file->copy(__DIR__ . '/stub/append.sh', $this->current . '/append.sh');
        }

        if ($input->getOption('aliases')) {
            if (!$this->file->exists($this->current . '/aliases')) {
                $this->file->copy(__DIR__ . '/stub/aliases', $this->current . '/aliases');
            }
        }
        /** @var string[] $configure */
        $configure = require __DIR__ . '/data/configure.php';
        $configure['name'] = ($input->getOption('name')) ? $input->getOption('name') : $this->defaultName;
        $configure['hostname'] = $input->getOption('hostname');
        $configure['ip'] = $input->getOption('ip');
        $configure['folders'][0]['map'] = $this->current;
        $configure['folders'][0]['to'] = str_replace('Code', $this->defaultName, $configure['folders'][0]['to']);

        $configure['sites'][0]['to'] = str_replace('Code', $this->defaultName, $configure['sites'][0]['to']);
        $fileExtension = mb_strtolower($input->getOption('filetype'));
        $publishMethod = 'to' . ucfirst($fileExtension);

        if (!$this->file->exists($this->current . "/vagrant.{$fileExtension}")) {
            file_put_contents($this->current . "/vagrant.{$fileExtension}", $this->file->$publishMethod($configure));
            return $output->writeln("<fg=cyan>success Gardening setup. see {$this->current}/vagrant.{$fileExtension}</>");
        }
        return $output->writeln("<fg=red>{$this->current}/vagrant.{$fileExtension} file exists.</>");
    }
}
