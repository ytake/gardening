<?php

namespace Ytake\Gardening\Foundation;

use Symfony\Component\Yaml\Dumper;

/**
 * Class Filer
 */
class Filer
{
    /** @var string  */
    protected $path;

    /**
     * @param $file
     *
     * @return bool
     */
    public function exists($file)
    {
        return file_exists($file);
    }

    /**
     * @param $source
     * @param $target
     *
     * @return bool
     */
    public function copy($source, $target)
    {
        return copy($source, $target);
    }

    /**
     * @param array $params
     *
     * @return string
     */
    public function toJson(array $params)
    {
        return json_encode($params, JSON_PRETTY_PRINT);
    }

    /**
     * @param array $params
     *
     * @return string
     */
    public function toYaml(array $params)
    {
        $dumper = new Dumper();
        return $dumper->dump($params, 3);
    }
}
