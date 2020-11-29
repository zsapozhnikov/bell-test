<?php

namespace App\DataFixtures;

use App\Entity\Author as AuthorEntity;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;

class Author extends Fixture
{
    public const AUTHOR_REFERENCE = 'author';

    public function load(ObjectManager $manager)
    {
        for ($i = 0; $i < 20; $i++) {
            $author = new AuthorEntity();
            $author->setFirstName('First '.$i);
            $author->setLastName('Last '.$i);
            $manager->persist($author);

            $this->addReference(self::AUTHOR_REFERENCE . '_' . $i, $author);
        }

        $manager->flush();
    }
}
