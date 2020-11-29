<?php

namespace App\DataTransformer;

use ApiPlatform\Core\DataTransformer\DataTransformerInterface;
use App\Entity\Author;

class CreateAuthorDataTransformer implements DataTransformerInterface
{

    public function transform($object, string $to, array $context = [])
    {
        $author = new Author();
        $author->setFirstName($object->firstName);
        $author->setLastName($object->lastName);

        return $author;
    }

    public function supportsTransformation($data, string $to, array $context = []): bool
    {
        if ($data instanceof Author) {
            return false;
        }

        return Author::class === $to && null !== ($context['input']['class'] ?? null);
    }
}
