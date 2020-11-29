<?php

namespace App\DataTransformer;

use ApiPlatform\Core\DataTransformer\DataTransformerInterface;
use App\Dto\AuthorOutput;
use App\Entity\Author;

class AuthorOutputDataTransformer implements DataTransformerInterface
{
    public function transform($object, string $to, array $context = [])
    {
        $author = new AuthorOutput();
        $author->id = $object->getId();
        $author->name = $object->getName();

        return $author;
    }

    public function supportsTransformation($data, string $to, array $context = []): bool
    {
        return AuthorOutput::class === $to && $data instanceof Author;
    }
}
